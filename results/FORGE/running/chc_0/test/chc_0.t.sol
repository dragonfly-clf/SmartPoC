// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CitysHome.sol";

contract BurnFeeQuery is CitysHome {
    function getBurnFee() public view returns (uint256) {
        return burnFee;
    }
}

contract CitysHomeTest is Test {
    BurnFeeQuery public token;
    address public owner = makeAddr("owner");
    
    function setUp() public {
        vm.startPrank(owner);
        token = new BurnFeeQuery();
        vm.stopPrank();
    }

    // Test that burn fee can be arbitrarily manipulated beyond 25%
    function testBurnFeeManipulation() public {
        uint MAX_PERCENTAGE = 25;

        console.log("\n--- BEFORE-Trigger Burn Fee ---");
        uint preBurnFee = token.getBurnFee();
        console.log("Initial Burn Fee: %", preBurnFee);
        assertLe(preBurnFee, MAX_PERCENTAGE, "Initial fee exceeds 25%");

        console.log("\n--- Trigger setBurnFee(100) ---");
        vm.prank(owner);
        token.setBurnFee(100); // Core attack action

        console.log("\n--- AFTER-Trigger Burn Fee ---");
        uint postBurnFee = token.getBurnFee();
        console.log("Final Burn Fee: %", postBurnFee);

        console.log("\n--- Vulnerability Verification ---");
        if (postBurnFee > MAX_PERCENTAGE) {
            console.log("Vulnerability Exists: Burn fee was set beyond 25%% limit");
        } else {
            console.log("Vulnerability not Exist: Burn fee remains within safe parameters");
        }
    }
}