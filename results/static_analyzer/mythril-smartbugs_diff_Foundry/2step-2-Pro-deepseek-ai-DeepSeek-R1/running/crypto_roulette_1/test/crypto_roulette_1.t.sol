// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/crypto_roulette.sol";

contract CryptoRouletteTest is Test {
    CryptoRoulette public roulette;
    uint256 public constant TEST_BET_PRICE = 1 ether;
    address public player = address(1);

    function setUp() public {
        roulette = new CryptoRoulette();
        vm.deal(player, TEST_BET_PRICE);
    }

    function test_ShuffleUnderflowAtBlockZero() public {
        console2.log("--- BEFORE Trigger ---");
        uint256 initialPlayerBalance = player.balance;
        console2.log("Block number set to 0");
        console2.log("Player balance: %s", initialPlayerBalance);

        // Set block number to 0 to force underflow
        vm.roll(0);
        
        console2.log("--- Trigger play() ---");
        bool vulnerable = false;
        string memory verdictReason;

        vm.prank(player);
        try roulette.play{value: TEST_BET_PRICE}(5) {
            vulnerable = true;
            verdictReason = "Underflow in shuffle() didn't revert and executed successfully at block 0";
            console2.log("--- AFTER Trigger ---");
            console2.log("play() executed successfully at block 0");
            console2.log("Player balance after: %s", player.balance);
        } catch Error(string memory reason) {
            vulnerable = false;
            verdictReason = string(abi.encodePacked("Reverted with reason: ", reason));
            console2.log("--- AFTER Trigger ---");
            console2.log("Error: %s", reason);
            console2.log("Player balance after: %s", player.balance);
        } catch (bytes memory) {
            vulnerable = false;
            verdictReason = "Reverted with a panic error (likely arithmetic underflow)";
            console2.log("--- AFTER Trigger ---");
            console2.log("Reverted with panic without reason string");
            console2.log("Player balance after: %s", player.balance);
        }
        
        // Final vulnerability verdict
        if (vulnerable) {
            console2.log("Vulnerability Exists: %s", verdictReason);
        } else {
            console2.log("Vulnerability not Exist: %s", verdictReason);
        }
    }
}