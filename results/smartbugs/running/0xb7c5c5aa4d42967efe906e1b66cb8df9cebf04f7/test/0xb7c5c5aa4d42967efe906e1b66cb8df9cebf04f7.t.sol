// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";

contract VulnerableKeepMyEther {
    mapping(address => uint256) public balances;
    uint256 public totalWithdrawals;
    
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function getUserStats(address user) public view returns (uint256 balance, uint256 deposits) {
        return (balances[user], balances[user] > 0 ? 1 : 0);
    }

    // Vulnerable version without require(success) check
    function withdraw() public {
        uint256 amount = balances[msg.sender];
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        // Intentionally missing require(success) check
        balances[msg.sender] = 0;
        totalWithdrawals += amount;
        emit Withdrawal(msg.sender,amount);
    }
}

contract KeepMyEtherTest is Test {
    VulnerableKeepMyEther public vulnerableContract;
    address payable user = payable(address(0x123));

    function setUp() public {
        vulnerableContract = new VulnerableKeepMyEther();
        vm.deal(user, 1 ether);
    }

    function testUncheckedWithdrawVulnerability() public {
        // User deposits ETH
        vm.prank(user);
        vulnerableContract.deposit{value: 1 ether}();

        // Record pre-trigger state
        uint256 userBalanceBefore = vulnerableContract.balances(user);
        uint256 totalWithdrawalsBefore = vulnerableContract.totalWithdrawals();
        uint256 contractBalanceBefore = address(vulnerableContract).balance;

        console2.log("--- BEFORE-Trigger ---");
        console2.log("User contract balance: %s", userBalanceBefore);
        console2.log("Total withdrawals: %s", totalWithdrawalsBefore);
        console2.log("Contract ETH balance: %s", contractBalanceBefore);
        console2.log("-----------------------------------");

        // Create a contract that will reject ETH transfers
        EthRejector rejector = new EthRejector();
        vm.etch(user, address(rejector).code);

        console2.log("--- Trigger Withdraw ---");
        vm.prank(user);
        vulnerableContract.withdraw();
        console2.log("-----------------------------------");

        // Record post-trigger state
        uint256 userBalanceAfter = vulnerableContract.balances(user);
        uint256 totalWithdrawalsAfter = vulnerableContract.totalWithdrawals();
        uint256 contractBalanceAfter = address(vulnerableContract).balance;

        console2.log("--- AFTER-Trigger ---");
        console2.log("User contract balance: %s", userBalanceAfter);
        console2.log("Total withdrawals: %s", totalWithdrawalsAfter);
        console2.log("Contract ETH balance: %s", contractBalanceAfter);
        console2.log("-----------------------------------");

        // Differential comparison
        bool userBalanceReset = (userBalanceAfter == 0);
        bool withdrawalsIncreased = (totalWithdrawalsAfter == totalWithdrawalsBefore + 1 ether);
        bool contractBalanceUnchanged = (contractBalanceAfter == contractBalanceBefore);

        console2.log("User balance reset: %s", userBalanceReset ? "YES" : "NO");
        console2.log("Withdrawals increased: %s", withdrawalsIncreased ? "YES" : "NO");
        console2.log("Contract balance unchanged: %s", contractBalanceUnchanged ? "YES" : "NO");

        // Final vulnerability verdict
        if (userBalanceReset && withdrawalsIncreased) {
            console2.log("Vulnerability Exists: User balance was reset and withdrawals increased despite failed ETH transfer");
        } else {
            console2.log("Vulnerability not Exist: State changes indicate proper withdrawal handling");
        }
    }
}

contract EthRejector {
    // This contract will reject all ETH transfers
    receive() external payable {
        revert("ETH transfers rejected");
    }
}