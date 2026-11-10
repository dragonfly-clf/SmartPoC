// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ERC20.sol";
import "forge-std/console.sol";

contract ERC20VulnerabilityTest is Test {
    ERC20 token;
    address owner = address(0x1);
    address recipient = address(0x2);
    address attacker = address(0x3);
    address internal zeroAddr = address(0);

    function setUp() public {
        vm.prank(owner);
        token = new ERC20(1000);
    }

    function testMessagePaddingVulnerability() public {
        // Transfer tokens to attacker for testing
        vm.prank(owner);
        token.transfer(attacker, 500);
        
        // Capture initial state BEFORE action
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialAttackerBalance = token.balanceOf(attacker);
        uint256 initialZeroAddressBalance = token.balanceOf(zeroAddr);
        console.log("Attacker balance (before): %s", initialAttackerBalance);
        console.log("Zero address balance (before): %s", initialZeroAddressBalance);

        console.log("--- Trigger: Attempt transfer to zero address with padded calldata ---");
        vm.prank(attacker);
        (bool success, ) = address(token).call(
            abi.encodeWithSelector(
                token.transfer.selector,
                bytes32(uint256(uint160(zeroAddr))),
                100
            )
        );
        console.log("Transaction status: %s", success ? "Success" : "Reverted");

        // Capture state AFTER action
        console.log("--- AFTER-Trigger State ---");
        uint256 finalAttackerBalance = token.balanceOf(attacker);
        uint256 finalZeroAddressBalance = token.balanceOf(zeroAddr);
        console.log("Attacker balance (after): %s", finalAttackerBalance);
        console.log("Zero address balance (after): %s", finalZeroAddressBalance);

        // Differential validation logic
        uint256 expectedChange = 100;
        bool attackerBalanceChanged = finalAttackerBalance == initialAttackerBalance - expectedChange;
        bool zeroAddrBalanceChanged = finalZeroAddressBalance == initialZeroAddressBalance + expectedChange;
        bool stateChangedUnexpectedly = attackerBalanceChanged && zeroAddrBalanceChanged;

        console.log("--- Vulnerability Verification ---");
        if (success && stateChangedUnexpectedly) {
            console.log("State changed as expected with transaction success");
            console.log("Vulnerability Exists: Transfer to zero address succeeded with padded calldata");
        } else if (!success) {
            console.log("State remains unchanged (expected patch behavior)");
            console.log("Vulnerability not Exist: Transaction reverted preventing zero address transfer");
        } else {
            console.log("Unexpected state change pattern detected");
            console.log("Vulnerability not Exist: Inconsistent state changes observed");
        }
    }
}