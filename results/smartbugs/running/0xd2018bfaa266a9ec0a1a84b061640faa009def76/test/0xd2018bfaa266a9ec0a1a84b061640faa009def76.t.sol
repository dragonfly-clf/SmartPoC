// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xd2018bfaa266a9ec0a1a84b061640faa009def76.sol";

contract PieTest is Test {
    Pie pie;
    address owner = address(0x1);
    address payable recipient = payable(address(0x4));
    address payable revertingContract;

    function setUp() public {
        vm.prank(owner);
        pie = new Pie();
        
        // Fund the owner with some ETH
        vm.deal(owner, 10 ether);

        // Create a contract that reverts on receive
        revertingContract = payable(address(new RevertingContract()));
    }

    function testUncheckedCallVulnerability() public {
        // Log vulnerability test start
        console.log("\n--- START testUncheckedCallVulnerability ---");
        
        console.log("--- BEFORE-Trigger ---");
        uint256 initialBalance = revertingContract.balance;
        console.log("ETH Balance of RevertingContract BEFORE attack: ", initialBalance);

        console.log("--- Trigger Action ---");
        // Owner tries to send ETH to a contract that will reject it
        vm.prank(owner);
        pie.Command{value: 1 ether}(revertingContract, "");

        console.log("--- AFTER-Trigger ---");
        uint256 afterBalance = revertingContract.balance;
        console.log("ETH Balance of RevertingContract AFTER attack: ", afterBalance);

        console.log("--- State Comparison ---");
        console.log("Balance change (Reversion expected):", afterBalance - initialBalance, "wei");
        
        console.log("--- Vulnerability Verdict ---");
        if (afterBalance == initialBalance) {
            console.log("Vulnerability Exists: ETH not transferred & transaction continued without revert (unchecked call vulnerability)");
        } else {
            console.log("Vulnerability not Exist: Unexpected balance change occurred");
        }

        // Original ETH transfer verification
        assertEq(afterBalance, initialBalance, "ETH should not have been transferred");
    }

    function testSuccessfulCall() public {
        uint256 initialBalance = recipient.balance;
        
        vm.prank(owner);
        pie.Command{value: 1 ether}(recipient, "");
        
        assertEq(recipient.balance, initialBalance + 1 ether, "ETH should have been transferred");
    }
}

contract RevertingContract {
    fallback() external payable {
        revert("This contract always reverts");
    }
}