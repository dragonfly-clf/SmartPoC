// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol";  // Add console2 for logging
import "../src/etherstore.sol";

contract Reverter {
    EtherStore public etherStore;

    constructor(address _etherStore) {
        etherStore = EtherStore(_etherStore);
    }

    function deposit() public payable {
        etherStore.depositFunds{value: msg.value}();
    }

    function withdraw() public {
        etherStore.withdrawFunds(etherStore.getUserBalance(address(this)));
    }

    receive() external payable {
        revert("Receive failed");
    }
}

contract EtherStoreCallTest is Test {
    EtherStore public etherStore;
    Reverter public reverter;
    uint256 public constant TEST_AMOUNT = 0.1 ether;
    address public user = makeAddr("user");

    function setUp() public {
        etherStore = new EtherStore();
        reverter = new Reverter(address(etherStore));

        // Fund the reverter contract
        deal(address(reverter), TEST_AMOUNT);
        reverter.deposit{value: TEST_AMOUNT}();

        // User deposits funds to EtherStore
        deal(user, TEST_AMOUNT);
        vm.prank(user);
        etherStore.depositFunds{value: TEST_AMOUNT}();

        // Fast forward time to pass withdrawal lock period
        vm.warp(block.timestamp + 1 weeks + 1);
    }

    function test_callFailureRevertsAndStatePreserved() public {
        // Confirm initial balance (sanity check)
        uint256 reverterInitialBalance = etherStore.getUserBalance(address(reverter));
        assertEq(reverterInitialBalance, TEST_AMOUNT);

        console2.log("--- BEFORE-Trigger Withdraw ---");
        // Record initial state values
        uint256 reverterBalanceBefore = etherStore.getUserBalance(address(reverter));
        uint256 userBalanceBefore = etherStore.getUserBalance(user);
        uint256 contractBalanceBefore = address(etherStore).balance;
        
        console2.log("Reverter balance:", reverterBalanceBefore);
        console2.log("User balance:", userBalanceBefore);
        console2.log("Contract balance:", contractBalanceBefore);

        console2.log("--- Trigger Withdraw ---");
        // Attempt withdrawal from reverter - should fail
        vm.expectRevert();
        reverter.withdraw();
        console2.log("Withdraw attempted and reverted as expected");

        console2.log("--- AFTER-Trigger Withdraw ---");
        // Record final state values
        uint256 reverterBalanceAfter = etherStore.getUserBalance(address(reverter));
        uint256 userBalanceAfter = etherStore.getUserBalance(user);
        uint256 contractBalanceAfter = address(etherStore).balance;
        
        console2.log("Reverter balance:", reverterBalanceAfter);
        console2.log("User balance:", userBalanceAfter);
        console2.log("Contract balance:", contractBalanceAfter);

        // Check state preservation
        bool statePreserved = (reverterBalanceBefore == reverterBalanceAfter) &&
                             (userBalanceBefore == userBalanceAfter) &&
                             (contractBalanceBefore == contractBalanceAfter);
        
        console2.log("State unchanged:", statePreserved ? "YES" : "NO");
        console2.log("Vulnerability Status:", statePreserved ? 
                     "Not exist - State preserved during failed call" : 
                     "Exists - State changed during failed call");

        // Final verdict output
        if (statePreserved) {
            console2.log("Vulnerability not Exist: State correctly preserved during external call failure");
        } else {
            console2.log("Vulnerability Exists: State changed despite external call reversion");
        }
    }
}