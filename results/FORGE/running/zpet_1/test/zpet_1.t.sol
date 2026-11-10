// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ZeusPet.sol";

contract ZeusPetExceedFeesTest is Test {
    ZeusPet public token;
    address owner = address(0x1);
    address marketingWallet = address(0x2);

    function setUp() public {
        vm.startPrank(owner);
        token = new ZeusPet(10, 10, marketingWallet);
        vm.stopPrank();
    }

    function test_SetFeePercentAbove25Percent() public {
        console.log("--- BEFORE-Trigger Fee Percent ---");
        // Record initial marketing and burn percentages
        uint256 initialMarketingFee = token.mktPct();
        uint256 initialBurnFee = token.burnPct();
        console.log("Initial Marketing Fee:", initialMarketingFee);
        console.log("Initial Burn Fee:", initialBurnFee);
        
        console.log("--- Trigger setFeePercent(20,15) ---");
        // Attempt to exceed maximum fee limit
        vm.prank(owner);
        token.setFeePercent(20, 15);
        
        console.log("--- AFTER-Trigger Fee Percent ---");
        // Capture new fee percentages after exploit attempt
        uint256 newMarketingFee = token.mktPct();
        uint256 newBurnFee = token.burnPct();
        console.log("Post-Manipulation Marketing Fee:", newMarketingFee);
        console.log("Post-Manipulation Burn Fee:", newBurnFee);
        
        // Validate if fees were changed to vulnerable values
        bool feeChanged = (initialMarketingFee != newMarketingFee) || 
                          (initialBurnFee != newBurnFee);
        bool exploitSuccess = (newBurnFee + newMarketingFee) > 25;
        
        // Final vulnerability verdict
        if (feeChanged && exploitSuccess) {
            console.log("Vulnerability Exists: Fees changed to", newBurnFee + newMarketingFee, "% exceeding 25% maximum");
        } else {
            console.log("Vulnerability not Exist: Fee constraint enforced (Total =", newBurnFee + newMarketingFee, "%)");
        }
    }
}