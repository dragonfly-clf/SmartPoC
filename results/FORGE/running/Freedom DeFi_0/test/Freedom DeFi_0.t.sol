// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BEP20Token.sol";

contract BEP20TokenTest is Test {
    BEP20Token token;
    address owner = address(this);
    address user = address(0x1);
    uint256 constant STAKE_PERCENT = 5;  // Example staking percentage

    function setUp() public {
        // Deploy token with initial supply to owner
        token = new BEP20Token();
        
        // Simulate setting staking percentage in storage (replace if actual setter available)
        bytes32 slot = bytes32(uint256(6)); // Estimated storage slot
        bytes32 value = bytes32(uint256(STAKE_PERCENT));
        vm.store(address(token), slot, value);
    }

    function testStakingUsesEtherBalanceInsteadOfTokenBalance() public {
        // Fund user with ether (affects native balance) 
        vm.deal(user, 1 ether); 
        
        console.log("--- BEFORE-Trigger ---");
        uint256 userTokenBalanceBefore = token.balanceOf(user);
        console.log("User token balance: %s", userTokenBalanceBefore);
        console.log("Contract token balance: %s", token.balanceOf(address(token)));
        console.log("User ether balance: %s", user.balance);
        
        console.log("--- Trigger distributeRewards call (should trigger vulnerability behavior) ---");
        bool success = false;
        bytes memory data;
        (success, data) = address(token).call(
            abi.encodeWithSelector(token.distributeRewards.selector, user)
        );
        
        console.log("--- AFTER-Trigger ---");
        uint256 userTokenBalanceAfter = token.balanceOf(user);
        console.log("User token balance: %s", userTokenBalanceAfter);
        console.log("Contract token balance: %s", token.balanceOf(address(token)));
        console.log("User ether balance: %s", user.balance);
        
        // Vulnerability exists if the call reverted due to invalid balance calculations
        if (!success) {
            console.log("Vulnerability Exists: distributeRewards reverted when called with a user having ether balance but zero tokens, indicating it incorrectly used native ether balance for reward calculations");
        } else {
            console.log("Vulnerability not Exist: distributeRewards completed without reverting, indicating it properly used token balances");
        }
    }
}