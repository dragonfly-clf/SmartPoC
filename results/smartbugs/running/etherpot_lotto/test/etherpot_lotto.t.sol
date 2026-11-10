// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/etherpot_lotto.sol";

contract LottoTest is Test {
    Lotto lotto;
    address payable nonPayableContract;
    
    function setUp() public {
        lotto = new Lotto();
        nonPayableContract = payable(address(new NonPayableContract()));
        
        // Send some ether to the contract to test with
        vm.deal(address(lotto), 10 ether);
    }

    function testUncheckedSendVulnerability() public {
        // Setup a round with a winner
        uint256 roundIndex = 0;
        uint256 subpotIndex = 0;
        
        // Clear existing mocks to get accurate state before test
        vm.clearMockedCalls();
        
        // Record initial states BEFORE trigger
        uint256 initialBalance = nonPayableContract.balance;
        bool initialIsCashed = lotto.getIsCashed(roundIndex, subpotIndex);
        
        console2.log("--- BEFORE-Trigger State ---");
        console2.log("Recipient balance:", initialBalance);
        console2.log("Initial isCashed:", initialIsCashed);
        
        // Mock necessary functions for the cash operation
        vm.mockCall(
            address(lotto),
            abi.encodeWithSelector(lotto.getSubpotsCount.selector, roundIndex),
            abi.encode(1)
        );
        vm.mockCall(
            address(lotto),
            abi.encodeWithSelector(lotto.getDecisionBlockNumber.selector, roundIndex, subpotIndex),
            abi.encode(block.number - 1)
        );
        vm.mockCall(
            address(lotto),
            abi.encodeWithSelector(lotto.calculateWinner.selector, roundIndex, subpotIndex),
            abi.encode(nonPayableContract)
        );
        vm.mockCall(
            address(lotto),
            abi.encodeWithSelector(lotto.getSubpot.selector, roundIndex),
            abi.encode(1 ether)
        );
        vm.mockCall(
            address(lotto),
            abi.encodeWithSelector(lotto.getIsCashed.selector, roundIndex, subpotIndex),
            abi.encode(false)
        );
        
        console2.log("--- Trigger: cash call ---");
        // Attempt to cash out to a non-payable contract
        lotto.cash(roundIndex, subpotIndex);
        
        console2.log("--- AFTER-Trigger State ---");
        // Clear all mocks to get real contract state
        vm.clearMockedCalls();
        
        // Record states AFTER trigger
        uint256 finalBalance = nonPayableContract.balance;
        bool finalIsCashed = lotto.getIsCashed(roundIndex, subpotIndex);
        
        console2.log("Recipient balance:", finalBalance);
        console2.log("Final isCashed:", finalIsCashed);
        
        // Vulnerability verification: 
        // ETH wasn't sent (balance unchanged) BUT state was updated
        bool balanceUnchanged = (finalBalance == initialBalance);
        bool stateChanged = (finalIsCashed != initialIsCashed);
        
        console2.log("Balance unchanged:", balanceUnchanged);
        console2.log("State changed:", stateChanged);
        
        // Final vulnerability verdict
        if (balanceUnchanged && stateChanged) {
            console2.log("Vulnerability Exists: ETH transfer failed but state was incorrectly updated");
        } else {
            console2.log("Vulnerability not Exist: Contract either failed to update state or successfully sent ETH");
        }
    }
}

contract NonPayableContract {
    // No payable fallback or receive function
    constructor() {}
}