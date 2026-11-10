// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LegendsDoge.sol";

contract LegendsDogeTest is Test {
    LegendsDoge token;
    address owner = makeAddr("owner");
    address charity = makeAddr("charity");
    address user = makeAddr("user");
    
    uint256 constant INITIAL_SUPPLY = 10000000 * 10**18;
    uint256 constant FEE_DECIMAL_FACTOR = 100;

    function setUp() public {
        vm.startPrank(owner);
        token = new LegendsDoge(
            "LegendsDoge",
            "LDOGE",
            18,                    // Decimals
            INITIAL_SUPPLY / 10**18, // Supply
            5,                     // Tax fee (0.05%)
            5,                     // Burn fee (0.05%)
            10,                    // Charity fee (0.10%)
            charity,               // Charity address
            owner                  // Token owner
        );
        
        // Configure limits to avoid test restrictions
        token.setMaxTxPercent(100);       // 100% of supply
        token.setMaxWalletPercent(100);   // 100% of supply
        
        // Add tokens to test user
        uint256 userBalance = 1000 * 10**token.decimals();
        token.transfer(user, userBalance);
        vm.stopPrank();
    }

    function testCharityTransferBalanceMismatch() public {
        // Set up: Exclude charity account to remove fees
        vm.prank(owner);
        token.excludeAccount(charity);

        uint256 transferAmount = 100 * 10**token.decimals();
        
        // BEFORE: Record pre-transfer balances
        uint256 initCharityBal = token.balanceOf(charity);
        uint256 initUserBal = token.balanceOf(user);
        uint256 initOwnerBal = token.balanceOf(owner);
        
        console.log("--- BEFORE Transfer State ---");
        console.log("Charity balance:", initCharityBal);
        console.log("User balance:", initUserBal);
        console.log("Owner balance:", initOwnerBal);
        
        console.log("--- Trigger Transfer Operation ---");
        // Execute transfer to charity address
        vm.prank(user);
        token.transfer(charity, transferAmount);
        console.log("Transfer triggered: %d tokens from user to charity", transferAmount);

        // AFTER: Record post-transfer balances
        uint256 afterCharityBal = token.balanceOf(charity);
        uint256 afterUserBal = token.balanceOf(user);
        uint256 afterOwnerBal = token.balanceOf(owner);
        
        console.log("--- AFTER Transfer State ---");
        console.log("Charity balance:", afterCharityBal);
        console.log("User balance:", afterUserBal);
        console.log("Owner balance:", afterOwnerBal);
        
        // Compute balance changes
        uint256 charityReceived = afterCharityBal - initCharityBal;
        uint256 userDebited = initUserBal - afterUserBal;
        uint256 ownerBalanceChange = afterOwnerBal - initOwnerBal;
        
        console.log("--- Balance Changes ---");
        console.log("Charity amount received:", charityReceived);
        console.log("User amount debited:", userDebited);
        console.log("Owner balance change:", ownerBalanceChange);

        // Vulnerability detection logic
        bool hasAddressBalanceMismatch = 
            charityReceived != transferAmount || 
            userDebited != transferAmount || 
            ownerBalanceChange != 0;
        
        // Final verification verdict
        if (hasAddressBalanceMismatch) {
            console.log("Vulnerability Exists: Address balances changed unexpectedly during charity transfer.");
        } else {
            console.log("Vulnerability not Exist: Balances changed as expected during charity transfer.");
        }
    }
}