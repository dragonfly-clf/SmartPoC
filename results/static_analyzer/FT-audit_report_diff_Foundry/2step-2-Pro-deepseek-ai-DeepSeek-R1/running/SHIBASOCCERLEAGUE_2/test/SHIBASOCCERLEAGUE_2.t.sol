// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SHIBASOCCERLEAGUE.sol";

contract UninitializedAmountTest is Test {
    SHIBASOCCERLEAGUE token;
    address owner = address(0x1);
    address alice = address(0xA);
    address bob = address(0xB);
    
    function setUp() public {
        // Create fork to access BSC contracts
        vm.createSelectFork("https://bsc-dataseed.binance.org/");
        
        // Deploy token
        vm.startPrank(owner);
        token = new SHIBASOCCERLEAGUE();
        
        // Configure token settings
        token.tradingEnable();
        token.setSwapBackSettings(false, 0);
        
        // Prepare exempt accounts list
        address[] memory exempts = new address[](1);
        exempts[0] = alice;
        
        // Set Alice as wallet/tx limit exempt
        token.manage_WalletLimitExempt(exempts, true);
        token.manage_TxLimitExempt(exempts, true);
        
        // Calculate safe initial transfer amount (10% of total supply)
        uint256 totalSupply = token.balanceOf(owner);
        uint256 safeAmount = totalSupply / 10;
        
        // Transfer to Alice
        token.transfer(alice, safeAmount);
        vm.stopPrank();
    }

    function testFeeExemptTransfer() public {
        // Disable Alice's fee exemption to test fee deduction scenario
        address[] memory aliceArr = new address[](1);
        aliceArr[0] = alice;
        vm.prank(owner);
        token.manage_FeeExempt(aliceArr, false);
        
        // Record initial balances
        uint256 initialAlice = token.balanceOf(alice);
        uint256 initialBob = token.balanceOf(bob);
        uint256 initialContract = token.balanceOf(address(token));
        
        console2.log("--- BEFORE-Trigger Transfer ---");
        console2.log("Alice balance: %d", initialAlice);
        console2.log("Bob balance: %d", initialBob);
        console2.log("Contract balance: %d", initialContract);
        
        // Get token settings for fees
        uint256 totalFee = token.totalFee();
        vm.assume(totalFee > 0); // Ensure fees are enabled
        uint256 feeDenom = token.feeDenominator();
        
        // Perform transfer (should take fees)
        uint256 transferAmount = initialAlice;
        console2.log("\n--- Trigger Transfer ---");
        vm.prank(alice);
        token.transfer(bob, transferAmount);
        
        // Record final balances
        uint256 finalAlice = token.balanceOf(alice);
        uint256 finalBob = token.balanceOf(bob);
        uint256 finalContract = token.balanceOf(address(token));
        
        console2.log("\n--- AFTER-Trigger Transfer ---");
        console2.log("Alice balance: %d", finalAlice);
        console2.log("Bob balance: %d", finalBob);
        console2.log("Contract balance: %d", finalContract);
        
        // Calculate for verification
        uint256 expectedFee = transferAmount * totalFee / feeDenom;
        
        // Differential validity check
        bool feeCalculationCorrect = 
            initialAlice - finalAlice == transferAmount &&
            finalBob - initialBob == transferAmount - expectedFee &&
            finalContract - initialContract == expectedFee;
            
        if (feeCalculationCorrect) {
            console2.log("\nVulnerability not Exist: Fee calculation is correct");
        } else {
            console2.log("\nVulnerability Exists: Fee calculation is incorrect due to uninitialized variable");
        }
        
        // Maintain original assertions
        assertEq(
            finalBob,
            initialBob + (transferAmount - expectedFee),
            "Bob didn't receive correct amount with fee"
        );
        assertEq(
            finalContract,
            initialContract + expectedFee,
            "Contract should collect fee amount"
        );
    }
}