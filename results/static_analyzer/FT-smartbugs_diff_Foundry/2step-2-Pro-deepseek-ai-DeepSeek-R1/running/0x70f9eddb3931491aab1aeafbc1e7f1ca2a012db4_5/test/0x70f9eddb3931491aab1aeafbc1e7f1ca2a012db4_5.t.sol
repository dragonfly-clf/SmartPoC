// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x70f9eddb3931491aab1aeafbc1e7f1ca2a012db4.sol";

contract MaliciousContract {
    event Received();
    
    function maliciousFunction() external payable {
        emit Received();
    }
    
    fallback() external payable {
        emit Received();
    }
    
    receive() external payable {
        emit Received();
    }
}

contract HomeyJarTest is Test {
    HomeyJar public jar;
    MaliciousContract public malicious;
    address public owner = makeAddr("owner");
    address public user = makeAddr("user");
    uint256 private constant INITIAL_BALANCE = 10 ether;

    function setUp() public {
        vm.prank(owner);
        jar = HomeyJar(payable(address(new HomeyJar())));
        vm.deal(owner, INITIAL_BALANCE);
        malicious = new MaliciousContract();
    }

    function test_CommandAllowsZeroAddress() public {
        console.log("--- BEFORE-Trigger Command to Zero Address ---");
        uint256 zeroBalanceBefore = address(0).balance;
        uint256 jarBalanceBefore = address(jar).balance;
        console.log("Zero address balance before:", zeroBalanceBefore);
        console.log("Jar contract balance before:", jarBalanceBefore);

        console.log("--- Trigger Command to Zero Address ---");
        vm.prank(owner);
        jar.Command{value: 0.1 ether}(address(0), abi.encodeWithSignature("nonExistentFunction()"));

        console.log("--- AFTER-Trigger Command to Zero Address ---");
        uint256 zeroBalanceAfter = address(0).balance;
        uint256 jarBalanceAfter = address(jar).balance;
        console.log("Zero address balance after:", zeroBalanceAfter);
        console.log("Jar contract balance after:", jarBalanceAfter);

        uint256 zeroBalanceDiff = zeroBalanceAfter - zeroBalanceBefore;
        
        if (zeroBalanceDiff == 0.1 ether) {
            console.log("Vulnerability Exists: Funds were transferred to the zero address");
        } else {
            console.log("Vulnerability not Exist: No funds transferred to zero address");
        }
    }

    function test_CommandAllowsEmptyData() public {
        console.log("--- BEFORE-Trigger Command with Empty Data ---");
        uint256 malBalanceBefore = address(malicious).balance;
        uint256 jarBalanceBefore = address(jar).balance;
        console.log("Malicious contract balance before:", malBalanceBefore);
        console.log("Jar contract balance before:", jarBalanceBefore);

        console.log("--- Trigger Command with Empty Data ---");
        vm.prank(owner);
        jar.Command{value: 0.1 ether}(address(malicious), "");

        console.log("--- AFTER-Trigger Command with Empty Data ---");
        uint256 malBalanceAfter = address(malicious).balance;
        uint256 jarBalanceAfter = address(jar).balance;
        console.log("Malicious contract balance after:", malBalanceAfter);
        console.log("Jar contract balance after:", jarBalanceAfter);

        uint256 malBalanceDiff = malBalanceAfter - malBalanceBefore;
        
        if (malBalanceDiff == 0.1 ether) {
            console.log("Vulnerability Exists: Funds were transferred with empty data");
        } else {
            console.log("Vulnerability not Exist: No funds transferred with empty data");
        }
    }

    function test_ValidCallSucceeds() public {
        uint256 initialMaliciousBalance = address(malicious).balance;
        vm.prank(owner);
        jar.Command{value: 1 ether}(address(malicious), abi.encodeWithSignature("maliciousFunction()"));
        
        assertEq(address(malicious).balance, initialMaliciousBalance + 1 ether);
    }

    function test_NonOwnerCannotCall() public {
        vm.prank(user);
        vm.expectRevert();
        jar.Command{value: 0}(address(this), abi.encodeWithSignature("maliciousFunction()"));
    }
}