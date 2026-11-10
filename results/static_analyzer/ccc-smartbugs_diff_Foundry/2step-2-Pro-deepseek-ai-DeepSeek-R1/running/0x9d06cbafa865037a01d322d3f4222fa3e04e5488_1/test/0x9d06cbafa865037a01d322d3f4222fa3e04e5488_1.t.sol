// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/0x9d06cbafa865037a01d322d3f4222fa3e04e5488.sol";

contract DeltaTest is Test {
    Delta public delta;
    address public owner = address(0x123);
    address public user = address(0x456);
    address public owner2 = address(0x789);
    address public token;
    
    // Mock token that always fails transferFrom
    error TransferFailed();

    function setUp() public {
        // Deploy mock token that reverts on transferFrom
        token = address(new FailingToken());
        
        vm.prank(owner);
        delta = new Delta();
        
        // Set storage directly to avoid initialization reverts
        // active (slot0) = 1, token_price (slot1) = 1 ether
        vm.store(address(delta), bytes32(uint256(0)), bytes32(uint256(1)));
        vm.store(address(delta), bytes32(uint256(1)), bytes32(uint256(1 ether)));
        
        // Set token address (c) at slot2 - address of failing token
        vm.store(address(delta), bytes32(uint256(2)), bytes32(uint256(uint160(token))));
        
        // owner2 at assumed slot3 + owner at slot4 (for transferFrom sender)
        vm.store(address(delta), bytes32(uint256(3)), bytes32(uint256(uint160(owner2))));
        vm.store(address(delta), bytes32(uint256(4)), bytes32(uint256(uint160(owner))));
        
        vm.deal(user, 10 ether);
    }

    function testTokenBuyDenialOfService() public {
        uint256 initialContractBalance = address(delta).balance;
        uint256 userInitialBalance = user.balance;
        uint256 depositAmount = 1 ether;

        console2.log("--- BEFORE-Trigger State ---");
        console2.log("Contract Delta ETH balance:", initialContractBalance);
        console2.log("User ETH balance:         ", userInitialBalance);

        console2.log("--- Trigger Token Buy ---");
        // User calls receive function which forwards to tokens_buy
        vm.prank(user);
        (bool sent,) = payable(address(delta)).call{value: depositAmount}("");

        console2.log("--- AFTER-Trigger State ---");
        uint256 postContractBalance = address(delta).balance;
        uint256 postUserBalance = user.balance;
        console2.log("Contract Delta ETH balance:", postContractBalance);
        console2.log("User ETH balance:         ", postUserBalance);

        // Compute state changes
        uint256 contractGain = postContractBalance - initialContractBalance;
        uint256 userLoss = userInitialBalance - postUserBalance;

        console2.log("--- State Change Analysis ---");
        console2.log("Contract balance gain:    ", contractGain);
        console2.log("User ETH balance loss:    ", userLoss);
        console2.log("Expected deposit amount:  ", depositAmount);

        // Final vulnerability check
        if (sent && contractGain == depositAmount && userLoss == depositAmount) {
            console2.log("VULNERABILITY VERDICT: ETH deposit accepted but tokens not transferred");
            console2.log("Vulnerability Exists: ETH was deposited and locked in contract without token transfer");
        } else {
            console2.log("VULNERABILITY VERDICT: Attack did not execute as expected");
            console2.log("Vulnerability not Exist: Unexpected behavior during token buy execution");
        }

        // Original assertions
        assertTrue(sent, "External call should succeed");
        assertEq(
            postContractBalance,
            initialContractBalance + depositAmount,
            "Funds should remain locked in contract"
        );
        assertEq(
            postUserBalance,
            userInitialBalance - depositAmount,
            "User should lose ETH without receiving tokens"
        );
    }
}

// Mock token that always reverts on transferFrom
contract FailingToken {
    function transferFrom(address, address, uint256) external pure returns (bool) {
        revert DeltaTest.TransferFailed();
    }
}