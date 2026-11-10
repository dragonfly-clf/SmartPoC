// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb37f18af15bafb869a065b61fc83cfc44ed9cc27.sol";

contract SimpleWalletTest is Test {
    SimpleWallet wallet;
    address owner = address(0x1);
    address receiver = address(0x3);

    function setUp() public {
        vm.startPrank(owner);
        wallet = new SimpleWallet();
        vm.deal(address(wallet), 10 ether); // Fund the wallet
        vm.stopPrank();
    }

    function testUncheckedSendMoney() public {
        // Create a contract that will reject ether transfers
        EtherRejector rejector = new EtherRejector();

        console.log(unicode"--- BEFORE-Trigger SendMoney ---");
        uint256 walletBalanceBefore = address(wallet).balance;
        uint256 rejectorBalanceBefore = address(rejector).balance;
        console.log(unicode"钱包合约余额 (before):", walletBalanceBefore);
        console.log(unicode"接收合约余额 (before):", rejectorBalanceBefore);
        assertEq(walletBalanceBefore, 10 ether, "Initial wallet balance should be 10 ether");
        assertEq(rejectorBalanceBefore, 0, "Initial rejector balance should be 0");

        console.log(unicode"--- Trigger SendMoney ---");
        vm.prank(owner);
        wallet.sendMoney(address(rejector), 1 ether);

        console.log(unicode"--- AFTER-Trigger SendMoney ---");
        uint256 walletBalanceAfter = address(wallet).balance;
        uint256 rejectorBalanceAfter = address(rejector).balance;
        console.log(unicode"钱包合约余额 (after):", walletBalanceAfter);
        console.log(unicode"接收合约余额 (after):", rejectorBalanceAfter);

        // Verify balances remain unchanged
        bool balancesUnchanged = (walletBalanceAfter == walletBalanceBefore) && 
                                 (rejectorBalanceAfter == rejectorBalanceBefore);
        
        console.log(unicode"余额是否未变化:", balancesUnchanged ? "Yes" : "No");
        console.log(unicode"漏洞利用是否成功:", balancesUnchanged ? "Success" : "Failure");

        // Final vulnerability verdict
        if (balancesUnchanged) {
            console.log("Vulnerability Exists: Transaction didn't revert and balances unchanged, proving unchecked low-level call vulnerability");
        } else {
            console.log("Vulnerability not Exist: Balances changed indicating proper revert handling");
        }

        // Maintain original assertions
        assertEq(rejectorBalanceAfter, 0);
        assertEq(walletBalanceAfter, 10 ether);
    }

    function testSuccessfulSendMoney() public {
        // Verify the wallet has balance
        assertEq(address(wallet).balance, 10 ether);

        // Record receiver's initial balance
        uint256 initialBalance = address(receiver).balance;

        // Send money successfully
        vm.prank(owner);
        wallet.sendMoney(receiver, 1 ether);

        // Verify balances updated correctly
        assertEq(address(receiver).balance, initialBalance + 1 ether);
        assertEq(address(wallet).balance, 9 ether);
    }
}

contract EtherRejector {
    fallback() external payable {
        revert("I reject ether");
    }
}