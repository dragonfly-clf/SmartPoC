// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/timed_crowdsale.sol";

contract TimedCrowdsaleTest is Test {
    TimedCrowdsale public crowdSale;
    address public owner = address(0x1234);
    address public user = address(0x5678);
    uint256 public constant HARDCODED_END_TIME = 1546300800;
    
    function setUp() public {
        vm.prank(owner);
        crowdSale = new TimedCrowdsale();
    }

    function test_SaleFinishState() public {
        // Set block timestamp just before hardcoded end time
        vm.warp(HARDCODED_END_TIME - 1);
        assertEq(crowdSale.isSaleFinished(), false, "Sale should not be finished");
        
        // Advance time to exactly end time
        vm.warp(HARDCODED_END_TIME);
        assertEq(crowdSale.isSaleFinished(), true, "Sale should be finished");
        
        console2.log("Vulnerability not Exist: Sale finish state correctly set at end time");
    }

    function test_CannotContributeAfterEndTime() public {
        // Advance to after hardcoded end time
        vm.warp(HARDCODED_END_TIME + 100 days);
        vm.deal(user, 1 ether);
        
        vm.prank(user);
        vm.expectRevert("Sale has finished");
        crowdSale.contribute{value: 1 ether}();
        
        console2.log("Vulnerability not Exist: Contribution after end time correctly prevented");
    }

    function test_WithdrawFundsSuccessfully() public {
        // Contribute before end time
        vm.warp(HARDCODED_END_TIME - 1 days);
        vm.deal(user, 1 ether);
        vm.prank(user);
        crowdSale.contribute{value: 1 ether}();
        
        // Advance to after end time
        vm.warp(HARDCODED_END_TIME + 1);
        
        // Record owner balance before withdrawal
        uint256 ownerBalanceBefore = owner.balance;
        
        // Verify funds can be withdrawn
        vm.prank(owner);
        crowdSale.withdrawFunds();
        
        // Check owner received funds
        assertEq(owner.balance - ownerBalanceBefore, 1 ether, "Owner should receive funds");
        assertEq(address(crowdSale).balance, 0, "Contract balance should be zero");
        
        console2.log("Vulnerability not Exist: Owner withdrawal of funds successful after end time");
    }

    function test_CannotWithdrawBeforeEndTime() public {
        // Contribute before end time
        vm.warp(HARDCODED_END_TIME - 1 days);
        vm.deal(user, 1 ether);
        vm.prank(user);
        crowdSale.contribute{value: 1 ether}();
        
        // Set time before end time
        vm.warp(HARDCODED_END_TIME - 1);
        
        // Verify withdrawal blocked
        vm.prank(owner);
        vm.expectRevert("Sale not finished yet");
        crowdSale.withdrawFunds();
        
        console2.log("Vulnerability not Exist: Withdrawal before end time correctly prevented");
    }
}