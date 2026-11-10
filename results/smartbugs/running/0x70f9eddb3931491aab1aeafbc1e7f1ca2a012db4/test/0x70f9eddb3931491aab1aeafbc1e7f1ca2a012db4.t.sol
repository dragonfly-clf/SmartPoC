// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x70f9eddb3931491aab1aeafbc1e7f1ca2a012db4.sol";

// Helper contract that will reject ETH transfers
contract NonPayableContract {
    function nonExistentFunction() external pure returns (bool) {
        return true;
    }
}

contract HomeyJarTest is Test {
    HomeyJar jar;
    NonPayableContract nonPayable;
    address owner = address(0x1);

    function setUp() public {
        vm.startPrank(owner);
        jar = new HomeyJar();
        nonPayable = new NonPayableContract();
        vm.deal(owner, 1 ether); // Fund owner instead of jar
        vm.stopPrank();
    }

    function testUncheckedCallVulnerability() public {
        // BEFORE: Record balances state
        uint256 ownerBalanceBefore = owner.balance;
        uint256 nonPayableBalanceBefore = address(nonPayable).balance;
        
        console.log("--- BEFORE-Trigger Command ---");
        console.log("Owner ETH balance:        ", ownerBalanceBefore);
        console.log("NonPayable ETH balance:   ", nonPayableBalanceBefore);

        // Trigger the vulnerability
        console.log("--- Trigger Command ---");
        // Create payload targeting the helper contract
        bytes memory payload = abi.encodeWithSignature("nonExistentFunction()");
        vm.prank(owner);
        jar.Command{value: 1 ether}(address(nonPayable), payload);
        
        // AFTER: Record balances state
        uint256 ownerBalanceAfter = owner.balance;
        uint256 nonPayableBalanceAfter = address(nonPayable).balance;
        
        console.log("--- AFTER-Trigger Command ---");
        console.log("Owner ETH balance:        ", ownerBalanceAfter);
        console.log("NonPayable ETH balance:   ", nonPayableBalanceAfter);
        
        // Calculate balance changes
        uint256 ownerLoss = ownerBalanceBefore - ownerBalanceAfter;
        uint256 nonPayableGain = nonPayableBalanceAfter - nonPayableBalanceBefore;
        
        console.log("--- Differential Results ---");
        console.log("Owner lost:               ", ownerLoss, " wei");
        console.log("NonPayable gained:        ", nonPayableGain, " wei");
        
        // Vulnerability exists if owner loses funds (1 ether) but nonPayable gains nothing
        if (ownerLoss > 0 && nonPayableGain == 0) {
            console.log("Vulnerability Exists: Owner lost ETH while nonPayable contract received 0");
        } else if (nonPayableGain > 0) {
            console.log("Vulnerability not Exist: NonPayable contract received the ETH transfer");
        } else {
            console.log("Vulnerability not Exist: No funds were lost during the transaction");
        }
    }
}