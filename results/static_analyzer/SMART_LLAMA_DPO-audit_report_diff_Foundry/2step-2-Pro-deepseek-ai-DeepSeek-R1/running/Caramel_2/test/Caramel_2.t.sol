// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Caramel.sol";

contract CaramelDoubleCountTest is Test {
    Caramel token;
    address owner = address(0x1);
    uint256 alicePrivateKey = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
    address alice;
    address delegatee = address(0x3);

    bytes32 public constant DOMAIN_TYPEHASH = 
        keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
    bytes32 public constant DELEGATION_TYPEHASH = 
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    function setUp() public {
        // Derive Alice's address from private key
        alice = vm.addr(alicePrivateKey);
        
        vm.startPrank(owner);
        token = new Caramel();
        token.mint(alice, 1000 ether);
        vm.stopPrank();
    }

    // Helper to get chainId without assembly in main function
    function getChainId() internal view returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }

    function testDelegateBySigNonceIncrement() public {
        console.log("--- BEFORE-Trigger Delegate ---");
        // Capture initial state values
        uint256 nonceBefore = token.nonces(alice);
        address delegateBefore = token.delegates(alice);
        uint256 delegateeVotesBefore = token.getCurrentVotes(delegatee);
        uint256 aliceBalance = token.balanceOf(alice);
        
        // Log state before delegation operations
        console.log("Initial nonce for Alice:       ", nonceBefore);
        console.log("Alice's initial delegate:      ", delegateBefore);
        console.log("Delegatee votes before:        ", delegateeVotesBefore);
        console.log("Alice's token balance:         ", aliceBalance);
        
        // Build delegation signature
        uint256 nonce = nonceBefore;
        uint256 expiry = block.timestamp + 100;
        uint256 chainId = getChainId();

        bytes32 domainSeparator = keccak256(abi.encode(
            DOMAIN_TYPEHASH,
            keccak256(bytes(token.name())),
            chainId,
            address(token)
        ));
        
        bytes32 structHash = keccak256(abi.encode(
            DELEGATION_TYPEHASH,
            delegatee,
            nonce,
            expiry
        ));
        
        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparator,
            structHash
        ));
        
        // Sign with Alice's private key
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePrivateKey, digest);

        console.log("--- Trigger First Delegation ---");
        vm.prank(alice);
        token.delegateBySig(
            delegatee, 
            nonce,
            expiry,
            v,
            r,
            s
        );

        console.log("--- AFTER-Trigger Delegate ---");
        // Log state after delegation using direct contract calls
        console.log("nonce (after):       ", token.nonces(alice));
        console.log("delegate (after):    ", token.delegates(alice));
        console.log("Delegatee votes (after):", token.getCurrentVotes(delegatee));
        
        console.log("------------------------------");
        console.log("DIFFERENTIAL VERIFICATION:");
        console.log("Nonce increased:     ", token.nonces(alice) == nonceBefore + 1 ? "YES" : "NO");
        console.log("Delegate updated:    ", 
            delegateBefore == address(0) && token.delegates(alice) == delegatee ? "YES" : "NO");
        console.log("Voting power updated:", 
            token.getCurrentVotes(delegatee) == delegateeVotesBefore + aliceBalance ? "YES" : "NO");
        console.log("------------------------------");
        
        // Final vulnerability determination with direct conditional checks
        if (token.nonces(alice) == nonceBefore + 1 &&
            delegateBefore == address(0) && 
            token.delegates(alice) == delegatee && 
            token.getCurrentVotes(delegatee) == delegateeVotesBefore + aliceBalance) 
        {
            console.log("Vulnerability not Exist: State updated correctly with nonce increment and proper vote delegation");
        } else {
            console.log("Vulnerability Exists: Critical state elements (nonce/delegate/votes) not updated correctly");
        }
        
        // Validate replay protection
        console.log("--- Trigger Second Delegation (Replay Check) ---");
        vm.prank(alice);
        vm.expectRevert("EGG::delegateBySig: invalid nonce");
        token.delegateBySig(
            delegatee, 
            nonce,
            expiry,
            v,
            r,
            s
        );
    }
}