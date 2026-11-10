// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x3e013fc32a54c4c5b6991ba539dcd0ec4355c859.sol";

contract CommandUncheckedCallTest is Test {
    MultiplicatorX4 public target;
    Reverter public reverter;
    
    function setUp() public {
        target = new MultiplicatorX4();
        reverter = new Reverter();
    }

    function testUncheckedCall() public {
        // Ensure test contract has sufficient ETH
        vm.deal(address(this), 1 ether);
        
        // Verify owner is test contract (deployer)
        assertEq(address(this), target.Owner());

        console.log("--- BEFORE-Trigger Balance ---");
        uint256 initialBalance = address(target).balance;
        console.log("Initial target balance: %s", initialBalance);

        console.log("--- Trigger Command ---");
        // Execute Command call to a reverting contract
        target.Command{value: 1 ether}(
            address(reverter),
            abi.encodeWithSignature("fakeFunction()")
        );
        
        console.log("--- AFTER-Trigger Balance ---");
        uint256 afterBalance = address(target).balance;
        console.log("After target balance: %s", afterBalance);

        if (afterBalance == initialBalance + 1 ether) {
            console.log("Vulnerability Exists: Contract retained 1 ether after failed call");
        } else {
            console.log("Vulnerability not Exist: Ether was not retained after failed call");
        }
    }
}

contract Reverter {
    fallback() external payable {
        revert("Reverter: forced failure");
    }
}