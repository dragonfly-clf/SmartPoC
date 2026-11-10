// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FidoMeta.sol";

contract FidoMeta_BurnMintTest is Test {
    Fidometa public token;
    address public owner = address(0x1234);

    function setUp() public {
        vm.startPrank(owner);
        token = new Fidometa();
        token.excludeFromReward(owner);
        vm.stopPrank();
    }

    // Test verifies burned tokens reduce total supply but excluded account balance remains unchanged
    function test_burn_does_not_reduce_excluded_balance() public {
        uint256 initialSupply = token.totalSupply();
        uint256 initialBalance = token.balanceOf(owner);

        // Differential Validation: BEFORE STATE
        console2.log("--- BEFORE-Trigger Burn ---");
        console2.log("Total supply:", initialSupply);
        console2.log("Owner balance:", initialBalance);

        uint256 burnAmount = 100;
        vm.prank(owner);
        token.burn(burnAmount);
        console2.log("--- Trigger Burn Operation ---");

        uint256 newSupply = token.totalSupply();
        uint256 newBalance = token.balanceOf(owner);

        // Differential Validation: AFTER STATE
        console2.log("--- AFTER-Trigger Burn ---");
        console2.log("Total supply:", newSupply);
        console2.log("Owner balance:", newBalance);

        // Differential Analysis
        bool supplyDecreased = newSupply == initialSupply - burnAmount;
        bool ownerBalanceUnchanged = newBalance == initialBalance;
        console2.log("Supply decreased correctly:", supplyDecreased ? "Yes" : "No");
        console2.log("Owner balance unchanged:", ownerBalanceUnchanged ? "Yes" : "No");
        
        // Vulnerability Determination
        if (!ownerBalanceUnchanged) {
            console2.log("Vulnerability Exists: Burn operation reduces excluded account balance");
        } else {
            console2.log("Vulnerability not Exist: Burn operation affects only total supply");
        }
    }

    // Test illustrates minting issue (though may not execute due to cap constraints)
    function test_mint_does_not_increase_excluded_balance() public {
        uint256 initialSupply = token.totalSupply();
        uint256 initialBalance = token.balanceOf(owner);
        uint256 amount = 100;

        // Differential Validation: BEFORE STATE
        console2.log("--- BEFORE-Trigger Burn+Mint ---");
        console2.log("Total supply:", initialSupply);
        console2.log("Owner balance:", initialBalance);

        vm.startPrank(owner);
        token.burn(amount);  // Create minting capacity
        console2.log("--- Trigger Burn Operation ---");
        
        // Intermediate state - needed for mint validation
        uint256 afterBurnSupply = token.totalSupply();
        uint256 afterBurnBalance = token.balanceOf(owner);
        console2.log("(Intermediate after burn)");
        console2.log("Total supply:", afterBurnSupply);
        console2.log("Owner balance:", afterBurnBalance);

        token.mint(amount);   // Attempt minting back
        console2.log("--- Trigger Mint Operation ---");
        vm.stopPrank();

        uint256 newSupply = token.totalSupply();
        uint256 newBalance = token.balanceOf(owner);

        // Differential Validation: AFTER STATE
        console2.log("--- AFTER-Trigger Mint ---");
        console2.log("Total supply:", newSupply);
        console2.log("Owner balance:", newBalance);

        // Differential Analysis
        bool supplyRecovered = newSupply == initialSupply;
        uint256 mintChange = newBalance - afterBurnBalance;
        bool ownerBalanceIncreased = mintChange == amount;
        console2.log("Supply recovered to initial:", supplyRecovered ? "Yes" : "No");
        console2.log("Balance change during mint:", mintChange);

        // Vulnerability Determination
        if (!ownerBalanceIncreased) {
            console2.log("Vulnerability Exists: Mint operation doesn't credit excluded account");
        } else {
            console2.log("Vulnerability not Exist: Mint operation correctly updates balance");
        }
    }
}