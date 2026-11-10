// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x806a6bd219f162442d992bdc4ee6eba1f2c5a707.sol";

contract CommandInputValidationTest is Test {
    Pie public targetContract;
    address public owner = makeAddr("owner");
    
    function setUp() public {
        vm.startPrank(owner);
        // Deploy the Pie contract
        targetContract = new Pie();
        vm.stopPrank();
    }

    function testZeroAddress() public {
        vm.deal(owner, 1 ether); // Fund owner account
        
        console2.log("--- BEFORE-Trigger Operation ---");
        console2.log("Calling Command(address(0), hex'12')...");

        console2.log("--- Trigger Operation ---");
        string memory verdict;
        vm.startPrank(owner);
        try targetContract.Command{value: 0.1 ether}(address(0), hex"12") {
            verdict = "Vulnerability Exists: Function call with zero address succeeded";
        } catch {
            verdict = "Vulnerability not Exist: Function call with zero address reverted";
        }
        vm.stopPrank();

        console2.log("--- AFTER-Trigger Operation ---");
        console2.log(verdict);
    }

    function testEmptyData() public {
        vm.deal(owner, 1 ether); // Fund owner account
        
        console2.log("--- BEFORE-Trigger Operation ---");
        console2.log("Calling Command(0x123, '')...");

        console2.log("--- Trigger Operation ---");
        string memory verdict;
        vm.startPrank(owner);
        try targetContract.Command{value: 0.1 ether}(address(0x123), "") {
            verdict = "Vulnerability Exists: Function call with empty data succeeded";
        } catch {
            verdict = "Vulnerability not Exist: Function call with empty data reverted";
        }
        vm.stopPrank();

        console2.log("--- AFTER-Trigger Operation ---");
        console2.log(verdict);
    }
}