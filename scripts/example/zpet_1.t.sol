// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/zpet_1.sol";

contract ZeusPetFeeTest is Test {
    ZeusPet token;
    address owner = address(0x1);
    address marketingWallet = address(0x2);
    address User1 = address(0x3);
    address User2 = address(0x4);

    function setUp() public {
        vm.startPrank(owner);
        token = new ZeusPet(10, 10, marketingWallet);
        vm.stopPrank();

        // Mint some initial tokens to normal and abnormal users
        vm.prank(owner);
        token.transfer(User1, 1000 ether);
        
        vm.prank(owner);
        token.transfer(User2, 1000 ether);
    }

    function testFeeComparison() public {
        // Normal behavior - fees within limit (10% each)
        uint256 User1BalanceBefore = token.balanceOf(User1);
        uint256 User2BalanceBefore = token.balanceOf(User2);

        vm.prank(User1);
        token.transfer(User2, 100 ether);

        uint256 User1BalanceAfter = token.balanceOf(User1);
        uint256 User2BalanceAfter = token.balanceOf(User2);
        uint256 OriginalFees = User1BalanceBefore + User2BalanceBefore - User1BalanceAfter - User2BalanceAfter;
        console2.log("Normal transfer fees", OriginalFees);

        // Abnormal behavior - fees exceed limit (30% each)
        vm.prank(owner);
        token.setFeePercent(30, 30);

        User1BalanceBefore = token.balanceOf(User1);
        User2BalanceBefore = token.balanceOf(User2);
        
        vm.prank(User1);
        token.transfer(User2, 100 ether);
        
        User1BalanceAfter = token.balanceOf(User1);
        User2BalanceAfter = token.balanceOf(User2);
        uint256 AfterFees = User1BalanceBefore + User2BalanceBefore - User1BalanceAfter - User2BalanceAfter;
        console2.log("Abnormal transfer fees", AfterFees);
        
        bool attackSuccessful = (AfterFees != OriginalFees);
        
        console2.log("Attack status:", attackSuccessful ? "SUCCESS" : "FAILED");
    }
}