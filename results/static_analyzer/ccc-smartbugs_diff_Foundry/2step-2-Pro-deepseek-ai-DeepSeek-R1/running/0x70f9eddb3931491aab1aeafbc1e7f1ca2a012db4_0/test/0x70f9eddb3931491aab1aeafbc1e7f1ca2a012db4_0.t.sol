// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x70f9eddb3931491aab1aeafbc1e7f1ca2a012db4.sol";

contract HomeyJarTest is Test {
    HomeyJar public honeyJar;
    address public owner = address(0x2f61E7e1023Bc22063B8da897d8323965a7712B7);
    address public user = address(0x456);
    uint256 constant AMOUNT = 1 ether;

    function setUp() public {
        honeyJar = new HomeyJar();
        vm.deal(address(honeyJar), AMOUNT);
    }

    function testWithdrawCausesDenialOfService() public {
        // Diff: BEFORE-Trigger Withdraw state snapshot
        console2.log("--- BEFORE-Trigger Withdraw ---");
        uint256 jarBalanceBeforeWithdraw = address(honeyJar).balance;
        uint256 userBalanceBeforeWithdraw = user.balance;
        console2.log("Contract ETH balance:", jarBalanceBeforeWithdraw);
        console2.log("User ETH balance:", userBalanceBeforeWithdraw);

        console2.log("--- Trigger Withdraw ---");
        // Verify initial contract balance
        uint256 initialJarBalance = address(honeyJar).balance;
        assertEq(initialJarBalance, AMOUNT, "Incorrect initial jar balance");

        // Owner withdraws all funds
        uint256 ownerBalanceBefore = owner.balance;
        vm.prank(owner);
        honeyJar.withdraw();

        console2.log("--- AFTER-Trigger Withdraw ---");
        uint256 jarBalanceAfterWithdraw = address(honeyJar).balance;
        uint256 userBalanceAfterWithdraw = user.balance;
        console2.log("Contract ETH balance:", jarBalanceAfterWithdraw);
        console2.log("User ETH balance:", userBalanceAfterWithdraw);

        // Verify funds transferred to owner
        uint256 ownerBalanceAfter = owner.balance;
        assertEq(
            ownerBalanceAfter,
            ownerBalanceBefore + AMOUNT,
            "Owner should receive contract balance"
        );
        assertEq(
            address(honeyJar).balance,
            0,
            "Jar should be empty after withdrawal"
        );

        console2.log("--- BEFORE-Trigger User Call ---");
        uint256 jarBalanceBeforeCall = address(honeyJar).balance;
        uint256 userBalanceBeforeCall = user.balance;
        console2.log("Contract ETH balance:", jarBalanceBeforeCall);
        console2.log("User ETH balance:", userBalanceBeforeCall);

        // User attempts to get honey
        console2.log("--- Trigger User Call (GetHoneyFromJar) ---");
        vm.prank(user);
        (bool success,) = address(honeyJar).call(
            abi.encodeWithSignature("GetHoneyFromJar()")
        );
        
        console2.log("--- AFTER-Trigger User Call ---");
        uint256 jarBalanceAfterCall = address(honeyJar).balance;
        uint256 userBalanceAfterCall = user.balance;
        console2.log("Contract ETH balance:", jarBalanceAfterCall);
        console2.log("User ETH balance:", userBalanceAfterCall);
        
        // Vulnerability detection
        bool userBalUnchanged = userBalanceAfterCall == userBalanceBeforeCall;
        bool contractBalUnchanged = jarBalanceAfterCall == jarBalanceBeforeCall;
        bool contractWasEmpty = jarBalanceBeforeCall == 0;
        
        bool vulnerabilityExists = userBalUnchanged && contractBalUnchanged && contractWasEmpty;
        
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Subsequent calls to GetHoneyFromJar had no effect after withdrawal, causing denial-of-service");
        } else {
            console2.log("Vulnerability not Exist: State changes indicate the DoS condition was not triggered");
        }
    }
}