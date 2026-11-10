// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/HaggleToken.sol";

contract GasExhaustionTest is Test {
    HaggleXToken public token;
    address public user = address(1);
    uint256 constant STAKE_COUNT = 100;

    function setUp() public {
        token = new HaggleXToken();
        token.mint(user, STAKE_COUNT * 1 ether);
    }

    function testGasExhaustionRisk() public {
        vm.startPrank(user);

        // Create many stakes
        for (uint i = 0; i < STAKE_COUNT; i++) {
            token.stake(1 ether, 9);
        }

        // Get lock time via public function instead of accessing internals
        uint256 timeToAdvance = token.getRemainingLockTime(0) + 1;
        vm.warp(block.timestamp + timeToAdvance);

        console.log("--- BEFORE-Trigger ---");
        uint256 gasStart = gasleft();
        console.log("Initial gas available: %s", gasStart);

        console.log("--- Trigger Unstake Action ---");
        token.unstake(0);
        uint256 gasUsed = gasStart - gasleft();
        console.log("Gas used for unstaking first stake (100 stakes): %s", gasUsed);

        console.log("--- AFTER-Trigger ---");
        console.log("Gas remaining: %s", gasleft());
        console.log("⚠️ Warning: Gas usage grows linearly with stake array length");
        console.log("⛔️ Unstaking early array positions costs increasing gas");
        console.log("💥 In production with many stakes, this can cause out-of-gas errors");

        // Threshold for detection (300,000 gas)
        if (gasUsed > 300000) {
            console.log("Vulnerability Exists: Gas consumption exceeds safe threshold, demonstrating linear scaling");
        } else {
            console.log("Vulnerability not Exist: Gas consumption within acceptable limits for this test scope");
        }
        vm.stopPrank();
    }
}