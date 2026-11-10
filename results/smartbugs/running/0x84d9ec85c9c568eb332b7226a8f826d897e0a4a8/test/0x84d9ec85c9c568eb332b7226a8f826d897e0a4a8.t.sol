// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x84d9ec85c9c568eb332b7226a8f826d897e0a4a8.sol";

contract WedIndexTest is Test {
    WedIndex wedIndex;
    address owner = address(0x1);
    address nonPayableContract = address(0x1234); // Using higher address to avoid precompile

    function setUp() public {
        vm.startPrank(owner);
        wedIndex = new WedIndex();
        vm.stopPrank();
        
        // Fund the WedIndex contract with ETH for testing
        vm.deal(address(wedIndex), 1 ether);
    }

    function testUncheckedLowLevelCall() public {
        // Create a contract that will reject ETH transfers
        MockNonPayable mock = new MockNonPayable();
        
        console.log("--- BEFORE-Trigger Call ---");
        uint256 initialBalance = address(wedIndex).balance;
        console.log("WedIndex ETH balance before: ", initialBalance);

        console.log("--- Trigger Execute Call ---");
        // Owner sends ETH to non-payable contract
        vm.prank(owner);
        // Execute call to non-payable contract with 1 ETH
        wedIndex.execute(address(mock), 1 ether, "");

        console.log("--- AFTER-Trigger Call ---");
        uint256 finalBalance = address(wedIndex).balance;
        console.log("WedIndex ETH balance after: ", finalBalance);

        if (initialBalance == finalBalance) {
            console.log("Vulnerability Exists: The call failed (balance unchanged) but the function did not revert, ignoring the failure.");
        } else {
            console.log("Vulnerability not Exist: The call succeeded? The balance changed, which should not happen with a non-payable contract.");
        }
    }

    function testProperCallHandling() public {
        // Create a contract that will reject ETH transfers
        MockNonPayable mock = new MockNonPayable();

        vm.prank(owner);
        
        // Execute call to non-payable contract with 1 ETH
        wedIndex.execute(address(mock), 1 ether, "");
        
        // Verify the contract still has its ETH (transfer failed)
        assertEq(address(wedIndex).balance, 1 ether, "ETH should not have been transferred");
    }
}

contract MockNonPayable {
    // This contract will reject any ETH transfers
    receive() external payable {
        revert("Non-payable contract");
    }
}