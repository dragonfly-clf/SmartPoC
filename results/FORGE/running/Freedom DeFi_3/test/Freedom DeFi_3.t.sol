// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BEP20Token.sol";

contract BEP20Token_OwnerPrivileges_Test is Test {
    BEP20Token token;
    address deployer;
    address rewardRecipient = address(0x2);
    uint256 initialSupply;

    function setUp() public {
        deployer = address(this);
        token = new BEP20Token();
        initialSupply = token.totalSupply();
    }

    function test_OwnerCanMintArbitraryTokens() public {
        uint256 mintAmount = 1000 * 10 ** token.decimals();
        
        console.log("--- BEFORE-Trigger Mint ---");
        uint256 pre_totalSupply = token.totalSupply();
        uint256 pre_balanceDeployer = token.balanceOf(deployer);
        uint256 pre_balanceRecipient = token.balanceOf(rewardRecipient);
        uint256 pre_stakingPercent = token._stakingPercent();
        
        console.log("Pre totalSupply: %s", pre_totalSupply);
        console.log("Pre deployer balance: %s", pre_balanceDeployer);
        console.log("Pre reward recipient balance: %s", pre_balanceRecipient);
        console.log("Pre stakingPercent: %s", pre_stakingPercent);
        
        console.log("--- Trigger Mint ---");
        token.mint(mintAmount);
        
        console.log("--- AFTER-Trigger Mint ---");
        uint256 post_totalSupply = token.totalSupply();
        uint256 post_balanceDeployer = token.balanceOf(deployer);
        uint256 post_balanceRecipient = token.balanceOf(rewardRecipient);
        uint256 post_stakingPercent = token._stakingPercent();
        
        console.log("Post totalSupply: %s", post_totalSupply);
        console.log("Post deployer balance: %s", post_balanceDeployer);
        console.log("Post reward recipient balance: %s", post_balanceRecipient);
        console.log("Post stakingPercent: %s", post_stakingPercent);
        
        // Differential verification
        bool mintTotalSupplyCorrect = post_totalSupply == pre_totalSupply + mintAmount;
        bool mintBalanceCorrect = post_balanceDeployer == pre_balanceDeployer + mintAmount;
        bool recipientUnchanged = post_balanceRecipient == pre_balanceRecipient;
        bool stakingPercentUnchanged = post_stakingPercent == pre_stakingPercent;
        
        console.log("State verification:");
        console.log("  Total supply increased correctly:", mintTotalSupplyCorrect);
        console.log("  Owner balance increased correctly:", mintBalanceCorrect);
        console.log("  Recipient balance unchanged:", recipientUnchanged);
        console.log("  Staking percent unchanged:", stakingPercentUnchanged);
        
        if (mintTotalSupplyCorrect && mintBalanceCorrect && recipientUnchanged && stakingPercentUnchanged) {
            console.log("Vulnerability Exists: Owner can mint arbitrary amounts without constraints");
        } else {
            console.log("Vulnerability not Exist: Mint operation did not produce expected state changes");
        }
        
        // Existing assertions
        assertEq(token.totalSupply(), initialSupply + mintAmount, "Total supply not increased");
        assertEq(token.balanceOf(deployer), pre_balanceDeployer + mintAmount, "Owner balance not increased");
    }

    function test_OwnerCanCallDistributeRewards() public {
        console.log("--- BEFORE-Trigger DistributeRewards ---");
        uint256 pre_totalSupply = token.totalSupply();
        uint256 pre_balanceDeployer = token.balanceOf(deployer);
        uint256 pre_balanceRecipient = token.balanceOf(rewardRecipient);
        uint256 pre_stakingPercent = token._stakingPercent();
        
        console.log("Pre totalSupply: %s", pre_totalSupply);
        console.log("Pre deployer balance: %s", pre_balanceDeployer);
        console.log("Pre reward recipient balance: %s", pre_balanceRecipient);
        console.log("Pre stakingPercent: %s", pre_stakingPercent);
        
        // Prepare for call with ether allocation (unrelated to tokens)
        vm.deal(rewardRecipient, 100 wei);
        
        console.log("--- Trigger DistributeRewards ---");
        token.distributeRewards(rewardRecipient);
        
        console.log("--- AFTER-Trigger DistributeRewards ---");
        uint256 post_totalSupply = token.totalSupply();
        uint256 post_balanceDeployer = token.balanceOf(deployer);
        uint256 post_balanceRecipient = token.balanceOf(rewardRecipient);
        uint256 post_stakingPercent = token._stakingPercent();
        
        console.log("Post totalSupply: %s", post_totalSupply);
        console.log("Post deployer balance: %s", post_balanceDeployer);
        console.log("Post reward recipient balance: %s", post_balanceRecipient);
        console.log("Post stakingPercent: %s", post_stakingPercent);
        
        // Differential verification
        bool totalSupplyUnchanged = post_totalSupply == pre_totalSupply;
        bool deployerEmptied = post_balanceDeployer == 0;
        bool recipientReceived = post_balanceRecipient == pre_balanceRecipient + pre_balanceDeployer;
        bool stakingPercentUnchanged = post_stakingPercent == pre_stakingPercent;
        
        console.log("State verification:");
        console.log("  Total supply unchanged:", totalSupplyUnchanged);
        console.log("  Owner balance cleared:", deployerEmptied);
        console.log("  Recipient received full amount:", recipientReceived);
        console.log("  Staking percent unchanged:", stakingPercentUnchanged);
        
        if (totalSupplyUnchanged && deployerEmptied && recipientReceived && stakingPercentUnchanged) {
            console.log("Vulnerability Exists: Owner can transfer entire token balance arbitrarily");
        } else {
            console.log("Vulnerability not Exist: distributeRewards produced unexpected state changes");
        }
        
        // Existing assertions using captured state
        assertLt(post_balanceDeployer, pre_balanceDeployer, "Owner token balance should decrease");
        assertGt(post_balanceRecipient, pre_balanceRecipient, "Recipient token balance should increase");
        assertEq(
            post_balanceRecipient - pre_balanceRecipient, 
            pre_balanceDeployer - post_balanceDeployer, 
            "Tokens should transfer 1:1"
        );
    }
}