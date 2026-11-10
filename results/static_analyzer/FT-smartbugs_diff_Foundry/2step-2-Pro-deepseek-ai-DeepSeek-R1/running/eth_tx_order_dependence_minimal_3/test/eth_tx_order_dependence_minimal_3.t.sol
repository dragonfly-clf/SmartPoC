// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/eth_tx_order_dependence_minimal.sol";

contract GasGuzzler {
    uint256 public dummy;
    
    function attack(EthTxOrderDependenceMinimal victim) external {
        victim.claimReward(5);
    }
    
    receive() external payable {
        dummy = 1; // Costs > 2300 gas
    }
}

contract UnprotectedTransferTest is Test {
    EthTxOrderDependenceMinimal public victim;
    GasGuzzler public gasGuzzler;
    address public owner = makeAddr("owner");
    
    function setUp() public {
        vm.deal(owner, 1 ether); // Fund owner
        vm.startPrank(owner);
        victim = new EthTxOrderDependenceMinimal();
        victim.setReward{value: 1 ether}(); // ETH comes from owner
        vm.stopPrank();
        
        gasGuzzler = new GasGuzzler();
    }
    
    function test_claimRewardRevertsWhenGasExceeds2300() public {
        console.log("--- BEFORE-Trigger State ---");
        // Snapshot initial state
        uint256 victimBalanceBefore = address(victim).balance;
        uint256 gasGuzzlerBalanceBefore = address(gasGuzzler).balance;
        bool claimedStatusBefore = victim.claimed();
        uint256 totalClaimsBefore = victim.totalClaims();
        uint256 userClaimsBefore = victim.userClaims(address(gasGuzzler));

        console.log("Victim ETH:", victimBalanceBefore);
        console.log("GasGuzzler ETH:", gasGuzzlerBalanceBefore);
        console.log("Reward Claim Status:", claimedStatusBefore);
        console.log("Total Claims:", totalClaimsBefore);
        console.log("GasGuzzler Claims:", userClaimsBefore);

        console.log("--- Trigger RemoveLimits ---");
        // Execute attack (expected to revert)
        vm.prank(address(gasGuzzler));
        vm.expectRevert();
        gasGuzzler.attack(victim);

        console.log("--- AFTER-Trigger State ---");
        // Snapshot post-attack state
        uint256 victimBalanceAfter = address(victim).balance;
        uint256 gasGuzzlerBalanceAfter = address(gasGuzzler).balance;
        bool claimedStatusAfter = victim.claimed();
        uint256 totalClaimsAfter = victim.totalClaims();
        uint256 userClaimsAfter = victim.userClaims(address(gasGuzzler));

        console.log("Victim ETH:", victimBalanceAfter);
        console.log("GasGuzzler ETH:", gasGuzzlerBalanceAfter);
        console.log("Reward Claim Status:", claimedStatusAfter);
        console.log("Total Claims:", totalClaimsAfter);
        console.log("GasGuzzler Claims:", userClaimsAfter);

        // Vulnerability assessment
        if (victimBalanceBefore != victimBalanceAfter ||
            gasGuzzlerBalanceBefore != gasGuzzlerBalanceAfter ||
            claimedStatusBefore != claimedStatusAfter ||
            totalClaimsBefore != totalClaimsAfter ||
            userClaimsBefore != userClaimsAfter) 
        {
            console.log("Vulnerability Exists: State changed despite expected revert");
        } else {
            console.log("Vulnerability not Exist: State unchanged; exploit contained");
        }
    }
}