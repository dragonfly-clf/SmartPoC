// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/eth_tx_order_dependence_minimal.sol";

contract DOS_Test is Test {
    EthTxOrderDependenceMinimal public targetContract;
    address owner = address(0x123);
    address user = address(0x456);

    function setUp() public {
        // Fund the owner with ETH for reward setting
        vm.deal(owner, 10 ether);
        
        // Deploy the contract as the owner
        vm.startPrank(owner);
        targetContract = new EthTxOrderDependenceMinimal();
        vm.stopPrank();
        
        // Fund the contract initially
        vm.startPrank(owner);
        targetContract.setReward{value: 1 ether}();
        vm.stopPrank();
    }

    function test_SetRewardAfterClaim_Reverts() public {
        console.log("--- BEFORE-Trigger claimed ---");
        // Check claimed status before any action
        bool claimedBefore = targetContract.claimed();
        console.log("Claimed status before: %s", claimedBefore);
        require(claimedBefore == false, "Claimed should be false initially");

        console.log("--- Trigger claimReward ---");
        // Claim the reward as a user
        vm.prank(user);
        targetContract.claimReward(9);  // Valid submission (<10)

        console.log("--- AFTER-Trigger claimed ---");
        // Check claimed status after claiming reward
        bool claimedAfter = targetContract.claimed();
        console.log("Claimed status after: %s", claimedAfter);
        require(claimedAfter == true, "Claimed should be true after claim");

        console.log("--- Verify setReward failure ---");
        // Attempt to set reward again (should revert)
        bool setRewardSuccess;
        vm.startPrank(owner);
        (setRewardSuccess, ) = address(targetContract).call{value: 1 ether}(
            abi.encodeWithSelector(targetContract.setReward.selector)
        );
        vm.stopPrank();
        
        // Final verdict logic
        if (claimedBefore == false && claimedAfter == true && !setRewardSuccess) {
            console.log("Vulnerability Exists: Claimed state changed from false to true and setReward reverted as expected");
        } else if (!setRewardSuccess) {
            console.log("Vulnerability not Exist: setReward failed but claimed state did not change correctly (before: %s, after: %s)", claimedBefore, claimedAfter);
        } else {
            console.log("Vulnerability not Exist: setReward succeeded unexpectedly");
        }
    }
}