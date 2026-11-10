// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb37f18af15bafb869a065b61fc83cfc44ed9cc27.sol";

contract MaliciousOwner {
    // Always revert when receiving ETH
    receive() external payable {
        revert();
    }
}

contract SimpleWalletTest is Test {
    SimpleWallet public wallet;
    MaliciousOwner public maliciousOwner;
    address payable public initialOwner = payable(address(0x1));
    address public user = address(0x2);
    uint256 public initialDeposit = 1 ether;

    function setUp() public {
        vm.deal(initialOwner, initialDeposit);
        vm.deal(user, initialDeposit);

        // Deploy wallet by initial owner
        vm.startPrank(initialOwner);
        wallet = new SimpleWallet();
        // Fund wallet with sufficient gas
        (bool success, ) = payable(address(wallet)).call{value: initialDeposit}("");
        require(success, "Funding failed");
        vm.stopPrank();

        // Deploy malicious owner contract
        maliciousOwner = new MaliciousOwner();

        // Overwrite owner address using direct storage manipulation
        bytes32 ownerSlot = bytes32(uint256(0)); // owner in slot 0
        bytes32 newOwner = bytes32(uint256(uint160(address(maliciousOwner))));
        vm.store(address(wallet), ownerSlot, newOwner);
    }

    function testWithdrawFailsWhenOwnerCannotReceiveETH() public {
        console.log("--- BEFORE-Trigger ---");
        uint256 walletBalanceBefore = address(wallet).balance;
        uint256 totalWithdrawnBefore = wallet.totalWithdrawn();
        console.log("Wallet contract balance:", walletBalanceBefore);
        console.log("Total withdrawn amount:", totalWithdrawnBefore);

        console.log("--- Trigger: Withdraw Call ---");
        // Attempt withdrawal (should fail)
        vm.startPrank(address(maliciousOwner));
        vm.expectRevert();
        wallet.withdraw(initialDeposit);
        vm.stopPrank();

        console.log("--- AFTER-Trigger ---");
        uint256 walletBalanceAfter = address(wallet).balance;
        uint256 totalWithdrawnAfter = wallet.totalWithdrawn();
        console.log("Wallet contract balance:", walletBalanceAfter);
        console.log("Total withdrawn amount:", totalWithdrawnAfter);
        
        // Compare states pre/post trigger
        bool fundsLocked = (walletBalanceAfter == walletBalanceBefore) && 
                           (totalWithdrawnAfter == totalWithdrawnBefore);
        
        if (fundsLocked) {
            console.log("Vulnerability Exists: Funds locked due to owner contract revert on ETH receive");
        } else {
            console.log("Vulnerability not Exist: State changed unexpectedly after withdraw call");
        }

        // Verify funds remain locked
        assertEq(address(wallet).balance, walletBalanceBefore, "Funds should be locked");
        assertEq(wallet.totalWithdrawn(), totalWithdrawnBefore, "Total withdrawn should remain unchanged");
    }

    function testWithdrawAllFailsWhenOwnerCannotReceiveETH() public {
        console.log("--- BEFORE-Trigger ---");
        uint256 walletBalanceBefore = address(wallet).balance;
        uint256 totalWithdrawnBefore = wallet.totalWithdrawn();
        console.log("Wallet contract balance:", walletBalanceBefore);
        console.log("Total withdrawn amount:", totalWithdrawnBefore);

        console.log("--- Trigger: WithdrawAll Call ---");
        // Attempt full withdrawal (should fail)
        vm.startPrank(address(maliciousOwner));
        vm.expectRevert();
        wallet.withdrawAll();
        vm.stopPrank();

        console.log("--- AFTER-Trigger ---");
        uint256 walletBalanceAfter = address(wallet).balance;
        uint256 totalWithdrawnAfter = wallet.totalWithdrawn();
        console.log("Wallet contract balance:", walletBalanceAfter);
        console.log("Total withdrawn amount:", totalWithdrawnAfter);
        
        // Compare states pre/post trigger
        bool fundsLocked = (walletBalanceAfter == walletBalanceBefore) && 
                           (totalWithdrawnAfter == totalWithdrawnBefore);
        
        if (fundsLocked) {
            console.log("Vulnerability Exists: Funds locked due to owner contract revert on ETH receive");
        } else {
            console.log("Vulnerability not Exist: State changed unexpectedly after withdrawAll call");
        }

        // Verify funds remain locked
        assertEq(address(wallet).balance, walletBalanceBefore, "Funds should be locked");
        assertEq(wallet.totalWithdrawn(), totalWithdrawnBefore, "Total withdrawn should remain unchanged");
    }
}