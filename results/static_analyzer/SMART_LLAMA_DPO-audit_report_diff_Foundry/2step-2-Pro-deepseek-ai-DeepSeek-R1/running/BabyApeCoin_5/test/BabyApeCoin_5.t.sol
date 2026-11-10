// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BabyApeCoin.sol";

contract MaliciousDelegatee {
    BabyApeCoin public token;
    address public attacker;

    constructor(BabyApeCoin _token) {
        token = _token;
        attacker = msg.sender;
    }

    function attemptMint(uint256 amount) external {
        token.mint(attacker, amount);
    }
}

contract BabyApeCoinAuditTest is Test {
    BabyApeCoin public token;
    MaliciousDelegatee public maliciousDelegate;
    address public owner = address(0x01);
    address public attacker;
    uint256 public constant TEST_AMOUNT = 100 ether;
    uint256 public constant TEST_SIGNATURE_VALIDITY = 1 days;
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");
    uint256 public chainId;
    uint256 public constant ATTACKER_PRIVATE_KEY = 0x123456;

    function setUp() public {
        // Get chainId using assembly
        uint256 _chainId;
        assembly {
            _chainId := chainid()
        }
        chainId = _chainId;

        // Derive attacker address using private key
        attacker = vm.addr(ATTACKER_PRIVATE_KEY);

        vm.startPrank(owner);
        token = new BabyApeCoin();
        maliciousDelegate = new MaliciousDelegatee(token);
        vm.stopPrank();
    }

    function testDelegateBypassFails() public {
        vm.startPrank(attacker);
        
        console.log("--- BEFORE-Trigger ---");
        uint256 attackerBalanceBefore = token.balanceOf(attacker);
        console.log("Attacker balance before attempt:", attackerBalanceBefore);

        // Attempt to set delegate to malicious contract
        token.delegate(address(maliciousDelegate));
        
        // Verify attacker cannot mint through delegate
        console.log("--- Trigger AttemptMint ---");
        (bool success,) = address(maliciousDelegate).call(
            abi.encodeWithSelector(MaliciousDelegatee.attemptMint.selector, TEST_AMOUNT)
        );
        
        console.log("--- AFTER-Trigger ---");
        uint256 attackerBalanceAfter = token.balanceOf(attacker);
        console.log("Attacker balance after attempt:", attackerBalanceAfter);
        
        // Differential verification
        bool exploitVerified = attackerBalanceAfter != attackerBalanceBefore;
        console.log("Balance change detected:", exploitVerified ? "YES" : "NO");
        console.log(exploitVerified 
            ? "Vulnerability Exists: Attacker balance increased improperly" 
            : "Vulnerability not Exist: Attacker balance unchanged"
        );

        assertFalse(success, "Malicious delegate bypassed access control");
        vm.stopPrank();
    }

    function testDelegateBySigBypassFails() public {
        console.log("--- BEFORE-Trigger ---");
        uint256 attackerBalanceBefore = token.balanceOf(attacker);
        console.log("Attacker balance before attempt:", attackerBalanceBefore);

        // User nonce starts at 0
        uint256 nonce = 0;
        uint256 expiry = block.timestamp + TEST_SIGNATURE_VALIDITY;

        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(token.name())),
                chainId,
                address(token)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                address(maliciousDelegate),
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        // Sign with attacker's private key
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ATTACKER_PRIVATE_KEY, digest);

        // Set delegate using signature
        token.delegateBySig(
            address(maliciousDelegate),
            nonce,
            expiry,
            v,
            r,
            s
        );

        console.log("--- Trigger AttemptMint ---");
        // Verify attacker cannot mint through delegate
        (bool success,) = address(maliciousDelegate).call(
            abi.encodeWithSelector(MaliciousDelegatee.attemptMint.selector, TEST_AMOUNT)
        );
        
        console.log("--- AFTER-Trigger ---");
        uint256 attackerBalanceAfter = token.balanceOf(attacker);
        console.log("Attacker balance after attempt:", attackerBalanceAfter);
        
        // Differential verification
        bool exploitVerified = attackerBalanceAfter != attackerBalanceBefore;
        console.log("Balance change detected:", exploitVerified ? "YES" : "NO");
        console.log(exploitVerified 
            ? "Vulnerability Exists: Attacker balance increased through delegate" 
            : "Vulnerability not Exist: No balance change detected"
        );

        assertFalse(success, "Malicious delegate bypassed access control via bySig");
    }
}