// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x7d09edb07d23acb532a82be3da5c17d9d85806b4.sol";

contract PoCGameTest is Test {
    PoCGame gameContract;
    address private whaleAddress = makeAddr("arbitraryWhale");
    address private player = makeAddr("player");
    uint256 private constant WAGER_LIMIT = 1 ether;

    function setUp() public {
        // Deploy contract with arbitrary whale address
        gameContract = new PoCGame(whaleAddress, WAGER_LIMIT);
        
        // Test contract is owner (deployer) so we call directly
        gameContract.OpenToThePublic();
        gameContract.AdjustDifficulty(1); // Force loss condition
        
        // Fund player
        vm.deal(player, 3 ether); // Adequate funds for wager and gas
        vm.deal(whaleAddress, 1 ether); // Ensure whale has fallback
    }

    function test_arbitrarySendToWhale() public {
        // Before trigger: capture initial state
        console2.log("--- BEFORE-Trigger State ---");
        uint256 prevWhaleBalance = whaleAddress.balance;
        uint256 prevContractBalance = address(gameContract).balance;
        console2.log("Whale Address Balance:", prevWhaleBalance);
        console2.log("Contract ETH Balance:", prevContractBalance);

        console2.log("--- Trigger Action: Player wager & play ---");
        // Player makes wager with proper origin/sender
        vm.startPrank(player, player);
        gameContract.wager{value: WAGER_LIMIT}();
        vm.stopPrank();

        // Move to next block to satisfy play() conditions
        vm.roll(block.number + 1);

        // Trigger loss condition with proper origin/sender
        vm.startPrank(player, player);
        gameContract.play();
        vm.stopPrank();

        // After trigger: capture final state
        console2.log("--- AFTER-Trigger State ---");
        uint256 currentWhaleBalance = whaleAddress.balance;
        uint256 currentContractBalance = address(gameContract).balance;
        console2.log("Whale Address Balance:", currentWhaleBalance);
        console2.log("Contract ETH Balance:", currentContractBalance);

        // Calculate and compare balance differences
        uint256 whaleBalanceDiff = currentWhaleBalance - prevWhaleBalance;
        uint256 expectedWhaleGain = WAGER_LIMIT / 2;
        bool whaleGainedFunds = whaleBalanceDiff == expectedWhaleGain;

        // Final vulnerability verdict
        if (whaleGainedFunds) {
            console2.log("Vulnerability Exists: Whale address received unauthorized ETH transfer");
        } else {
            console2.log("Vulnerability not Exist: No unauthorized ETH transfer detected");
        }

        // Original test assertion
        assertEq(whaleBalanceDiff, expectedWhaleGain, "ETH should be sent to arbitrary whale address");
    }
}