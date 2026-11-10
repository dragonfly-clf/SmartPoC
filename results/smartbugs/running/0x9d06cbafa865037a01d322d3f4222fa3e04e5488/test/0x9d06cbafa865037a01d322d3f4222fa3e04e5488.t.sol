// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x9d06cbafa865037a01d322d3f4222fa3e04e5488.sol";

contract Reverter {
    fallback() external payable {
        revert();
    }
}

contract DeltaTest is Test {
    Delta delta;
    Reverter reverter;
    address owner = address(0x1);
    address tokenContract = address(0x5);
    
    function setUp() public {
        vm.startPrank(owner);
        delta = new Delta();
        reverter = new Reverter();
        
        // Initialize contract state using storage slots
        vm.store(address(delta), bytes32(uint256(1)), bytes32(uint256(1))); // active
        vm.store(address(delta), bytes32(uint256(2)), bytes32(uint256(1 ether))); // token_price
        vm.store(address(delta), bytes32(uint256(3)), bytes32(uint256(uint160(tokenContract)))); // token contract
        vm.store(address(delta), bytes32(uint256(4)), bytes32(uint256(uint160(address(reverter))))); // owner2 = reverter
        
        vm.deal(address(delta), 10 ether);
        vm.stopPrank();
    }

    function testUncheckedSendVulnerability() public {
        console2.log("--- BEFORE-Trigger Balance ---");
        uint256 reverterBalanceBefore = address(reverter).balance;
        uint256 deltaBalanceBefore = address(delta).balance;
        console2.log("Reverter contract balance (before):", reverterBalanceBefore);
        console2.log("Delta contract balance (before):", deltaBalanceBefore);

        // Mock token transferFrom to succeed
        vm.mockCall(
            tokenContract,
            abi.encodeWithSignature("transferFrom(address,address,uint256)", address(owner), address(this), 1 ether),
            abi.encode(true)
        );

        console2.log("--- Trigger Unchecked Send ---");
        vm.deal(address(this), 1 ether);
        try delta.tokens_buy{value: 1 ether}() {
            // Continue if no revert occurs (vulnerability exists)
            console2.log("Transaction did not revert despite failed send");
        } catch {
            // Transaction reverted (vulnerability fixed)
            console2.log("Transaction reverted during tokens_buy");
        }

        console2.log("--- AFTER-Trigger Balance ---");
        uint256 reverterBalanceAfter = address(reverter).balance;
        uint256 deltaBalanceAfter = address(delta).balance;
        console2.log("Reverter contract balance (after):", reverterBalanceAfter);
        console2.log("Delta contract balance (after):", deltaBalanceAfter);
        console2.log("Balance change - Reverter:", (reverterBalanceAfter - reverterBalanceBefore));
        console2.log("Balance change - Delta:", (deltaBalanceAfter - deltaBalanceBefore));
        
        // Verdict based on behavior observation
        if (reverterBalanceAfter == 0 && deltaBalanceAfter == deltaBalanceBefore + 1 ether) {
            console2.log("Vulnerability Exists: Funds were not sent to Reverter but transaction completed");
        } else {
            console2.log("Vulnerability not Exist: Failed send caused revert or funds transferred");
        }
    }
}