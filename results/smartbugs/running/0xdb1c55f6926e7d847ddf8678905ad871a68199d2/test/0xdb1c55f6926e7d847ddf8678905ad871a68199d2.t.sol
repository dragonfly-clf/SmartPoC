// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xdb1c55f6926e7d847ddf8678905ad871a68199d2.sol";

contract FreeEthTest is Test {
    FreeEth freeEth;
    address owner = address(0x1);
    address attacker = address(0x2);
    address payable contractWithRevertingFallback;

    function setUp() public {
        vm.startPrank(owner);
        freeEth = new FreeEth();
        vm.deal(owner, 1 ether);
        
        // Deploy a contract that reverts on receive instead of using precompile
        contractWithRevertingFallback = payable(address(new RevertingContract()));
        vm.stopPrank();
    }

    function testUncheckedLowLevelCall() public {
        console.log("--- BEFORE-Trigger Balances ---");
        uint256 ownerBalanceBefore = owner.balance;
        uint256 contractBalanceBefore = address(freeEth).balance;
        uint256 targetBalanceBefore = contractWithRevertingFallback.balance;
        console.log("Owner ETH balance:", ownerBalanceBefore);
        console.log("FreeEth contract ETH balance:", contractBalanceBefore);
        console.log("Reverting contract ETH balance:", targetBalanceBefore);
        
        console.log("");
        console.log("--- Trigger Command ---");
        bytes memory data = "";
        vm.prank(owner);
        freeEth.Command{value: 1 ether}(contractWithRevertingFallback, data);
        console.log("Executed Command with 1 ETH to reverting contract");
        console.log("");
        
        console.log("--- AFTER-Trigger Balances ---");
        uint256 ownerBalanceAfter = owner.balance;
        uint256 contractBalanceAfter = address(freeEth).balance;
        uint256 targetBalanceAfter = contractWithRevertingFallback.balance;
        console.log("Owner ETH balance:", ownerBalanceAfter);
        console.log("FreeEth contract ETH balance:", contractBalanceAfter);
        console.log("Reverting contract ETH balance:", targetBalanceAfter);
        console.log("");
        
        console.log("--- Balance Changes ---");
        console.log("Owner balance change:", ownerBalanceBefore - ownerBalanceAfter);
        console.log("FreeEth contract balance change:", contractBalanceAfter - contractBalanceBefore);
        console.log("Target contract balance change:", targetBalanceAfter - targetBalanceBefore);
        console.log("");
        
        // Check if state changed as expected for vulnerability
        bool ownerLostETH = ownerBalanceAfter == ownerBalanceBefore - 1 ether;
        bool ethStuckInContract = contractBalanceAfter == contractBalanceBefore + 1 ether;
        bool targetNoChange = targetBalanceAfter == targetBalanceBefore;
        bool vulnerabilityExists = ownerLostETH && ethStuckInContract && targetNoChange;
        
        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: ETH stuck in FreeEth contract after failed transfer");
        } else {
            console.log("Vulnerability not Exist: ETH was returned/recovered after failed transfer");
        }
        
        // Fail test if vulnerability doesn't exist
        assertTrue(vulnerabilityExists, "Vulnerability validation failed");
    }

    function testSuccessfulLowLevelCall() public {
        // Send to a regular address should work
        address payable recipient = payable(address(0x4));
        uint256 initialBalance = recipient.balance;

        vm.prank(owner);
        bytes memory data = "";
        freeEth.Command{value: 1 ether}(recipient, data);

        assertEq(recipient.balance, initialBalance + 1 ether, "ETH transfer failed");
    }
}

contract RevertingContract {
    fallback() external payable {
        revert("This contract always reverts");
    }
}