// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/simple_dao.sol";

contract SimpleDAO_Test is Test {
    SimpleDAO public dao;
    address public alice = makeAddr("alice");

    function setUp() public {
        dao = new SimpleDAO();
        // Fund Alice with 1 ether
        vm.deal(alice, 1 ether);
        
        // Alice donates to herself to get credit
        vm.prank(alice);
        dao.donate{value: 1 ether}(alice);
    }

    function test_ZeroWithdraw() public {
        // Pre-trigger state capture
        console2.log("--- BEFORE-Trigger State ---");
        uint256 preContractBalance = dao.getContractBalance();
        uint256 preCredit = dao.queryCredit(alice);
        uint256 preWithdrawalsCount = dao.totalWithdrawals();
        console2.log("Contract Balance (pre):", preContractBalance);
        console2.log("Alice Credit (pre):     ", preCredit);
        console2.log("Withdrawals Count (pre):", preWithdrawalsCount);

        console2.log("--- Trigger: withdraw(0) ---");
        vm.prank(alice);
        dao.withdraw(0);

        // Post-trigger state capture
        console2.log("--- AFTER-Trigger State ---");
        uint256 postContractBalance = dao.getContractBalance();
        uint256 postCredit = dao.queryCredit(alice);
        uint256 postWithdrawalsCount = dao.totalWithdrawals();
        console2.log("Contract Balance (post):", postContractBalance);
        console2.log("Alice Credit (post):    ", postCredit);
        console2.log("Withdrawals Count (post):", postWithdrawalsCount);

        // Vulnerability verification
        bool stateChanged = false;
        string memory reason = "No state change detected";

        if (preContractBalance != postContractBalance) {
            stateChanged = true;
            reason = "Contract balance changed";
        } else if (preCredit != postCredit) {
            stateChanged = true;
            reason = "User credit changed";
        } else if (preWithdrawalsCount != postWithdrawalsCount) {
            stateChanged = true;
            reason = "Withdrawals count changed";
        }

        // Final vulnerability verdict
        if (stateChanged) {
            console2.log("Vulnerability Exists: %s", reason);
        } else {
            console2.log("Vulnerability not Exist: %s", reason);
        }
    }
}