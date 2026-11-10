// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/$solar_1.sol";

contract SOLIUMRISEFeeTest is Test {
    SOLIUMRISE token;
    address owner = address(0x1);
    address user1 = address(0x2);
    address user2 = address(0x3);

    function tokenAmount(uint256 amount) internal pure returns (uint256) {
        return amount * 10**4; 
    }

    function setUp() public {
        vm.startPrank(owner);
        token = new SOLIUMRISE();
        

        token.tradingStatus(true);

        // Mint some initial tokens to users
        token.transfer(user1, tokenAmount(1000));
        vm.stopPrank();
    }

    function testFeeManipulation() public {
        // Initial transfer with default fees
        uint256 user1BalanceBefore = token.balanceOf(user1);
        uint256 user2BalanceBefore = token.balanceOf(user2);

        vm.prank(user1);
        token.transfer(user2, tokenAmount(100));

        uint256 user1BalanceAfter = token.balanceOf(user1);
        uint256 user2BalanceAfter = token.balanceOf(user2);
        uint256 initialFees = (user1BalanceBefore + user2BalanceBefore) - (user1BalanceAfter + user2BalanceAfter);
        console2.log("Initial transfer fees:", initialFees);

        // Owner sets fees to maximum allowed (<50%)
        vm.prank(owner);
        token.setFees(10, 10, 10, 10, 5, 4, 100);

        // Owner sets sell multiplier to high value
        vm.prank(owner);
        token.set_sell_multiplier(1000);

        // Transfer after fee manipulation
        user1BalanceBefore = token.balanceOf(user1);
        user2BalanceBefore = token.balanceOf(user2);

        vm.prank(user1);
        token.transfer(user2, tokenAmount(100));

        user1BalanceAfter = token.balanceOf(user1);
        user2BalanceAfter = token.balanceOf(user2);
        uint256 manipulatedFees = (user1BalanceBefore + user2BalanceBefore) - (user1BalanceAfter + user2BalanceAfter);
        console2.log("Manipulated transfer fees:", manipulatedFees);

        bool feesExceedLimit = manipulatedFees > initialFees * 2;
        console2.log("Fees exceed limit:", feesExceedLimit ? "YES" : "NO");
    }
}