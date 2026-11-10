// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PINUToken.sol";

contract BadToken {
    mapping(address => uint256) public balanceOf;

    function transferFrom(address, address, uint256) external pure returns (bool) {
        return false; // Always returns failure to simulate non-compliant token
    }
}

contract MockPinkAntiBot {
    function setTokenOwner(address) external {}
}

contract PINUTokenTest is Test {
    PINUToken token;
    BadToken badToken;
    MockPinkAntiBot mockPinkAntiBot;
    address public owner = address(0x1);
    address public alice = address(0xA11ce);
    uint256 public supplyToAlice = 5e28; // Represents 50% of total supply (1e29)

    function setUp() public {
        vm.startPrank(owner);
        mockPinkAntiBot = new MockPinkAntiBot();
        badToken = new BadToken();
        address[] memory pairTokens = new address[](0);
        
        token = new PINUToken(
            address(mockPinkAntiBot),
            pairTokens,
            address(badToken)
        );
        
        // Distribute half the total supply to Alice to make her a significant holder
        token.transfer(alice, supplyToAlice);
        vm.stopPrank();
    }

    function test_IgnoredTransferFailureInDepositReward() public {
        uint256 depositAmount = 100e18;
        uint256 expectedReward = depositAmount; // Alice should get 100% of rewards

        console.log("--- BEFORE-Trigger Deposit ---");
        // Check Alice's reward balance and token balance of contract
        uint256 aliceRewardBefore = token.getRewardByAddressAndToken(alice, address(badToken));
        uint256 contractTokenBalanceBefore = badToken.balanceOf(address(token));
        console.log("Alice's pending reward (before):", aliceRewardBefore);
        console.log("Contract's badToken balance (before):", contractTokenBalanceBefore);
        
        console.log("--- Trigger depositReward ---");
        vm.startPrank(owner);
        token.depositReward(depositAmount); // Should ignore failed transfer and proceed
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger Deposit ---");
        // Check balances after depositReward call
        uint256 aliceRewardAfter = token.getRewardByAddressAndToken(alice, address(badToken));
        uint256 contractTokenBalanceAfter = badToken.balanceOf(address(token));
        console.log("Alice's pending reward (after):", aliceRewardAfter);
        console.log("Contract's badToken balance (after):", contractTokenBalanceAfter);
        
        // Compare state changes
        bool rewardIncreased = (aliceRewardAfter == aliceRewardBefore + depositAmount);
        bool contractBalanceUnchanged = (contractTokenBalanceAfter == contractTokenBalanceBefore);
        console.log("Reward increased as expected:", rewardIncreased ? "YES" : "NO");
        console.log("Contract's token balance unchanged:", contractBalanceUnchanged ? "YES" : "NO");

        // Final vulnerability verdict
        if (rewardIncreased && contractBalanceUnchanged) {
            console.log("Vulnerability Exists: The reward was allocated without a corresponding token transfer");
        } else {
            console.log("Vulnerability not Exist: Reward allocation and token transfer behaved correctly");
        }
    }
}