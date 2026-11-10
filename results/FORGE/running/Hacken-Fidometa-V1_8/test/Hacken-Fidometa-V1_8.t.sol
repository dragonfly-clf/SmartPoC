// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FidoMeta.sol";

contract Issue3 is Test {
    Fidometa token;
    address owner = address(0x1234); // Owner address

    function setUp() public {
        vm.startPrank(owner);
        token = new Fidometa(); // Deploy token with owner
        vm.stopPrank();
    }

    function testBurnAfterExclusion() public {
        // Record initial state
        uint256 initialSupply = token.totalSupply();
        uint256 ownerBalance = token.balanceOf(owner);
        assertEq(ownerBalance, initialSupply, "Initial owner balance mismatched");

        // Exclude owner from rewards
        vm.prank(owner);
        token.excludeFromReward(owner);

        console2.log("--- BEFORE-Trigger Burn ---");
        uint256 preBurnSupply = token.totalSupply();
        uint256 preBurnOwnerBalance = token.balanceOf(owner);
        console2.log("Total Supply:", preBurnSupply);
        console2.log("Owner Balance:", preBurnOwnerBalance);

        console2.log("--- Trigger Burn ---");
        console2.log("Burning %s tokens from owner", ownerBalance);
        
        // Burn all tokens owned by the owner
        vm.prank(owner);
        token.burn(ownerBalance);

        console2.log("--- AFTER-Trigger Burn ---");
        uint256 postBurnSupply = token.totalSupply();
        uint256 postBurnOwnerBalance = token.balanceOf(owner);
        console2.log("Total Supply:", postBurnSupply);
        console2.log("Owner Balance:", postBurnOwnerBalance);
        
        console2.log("--- DIFFERENTIAL COMPARISON ---");
        console2.log("Supply Change: %s -> %s", preBurnSupply, postBurnSupply);
        console2.log("Owner Balance Change: %s -> %s", preBurnOwnerBalance, postBurnOwnerBalance);
        
        // Check state inconsistency indicating vulnerability
        bool stateInconsistent = (postBurnSupply == 0) && (postBurnOwnerBalance == preBurnOwnerBalance);
        if (stateInconsistent) {
            console2.log("Verdict: Total supply reduced to zero but owner balance remains unchanged");
            console2.log("Vulnerability Exists: Burn operation doesn't update balance when excluded from rewards");
        } else {
            console2.log("Verdict: Owner balance updated after burn as expected");
            console2.log("Vulnerability not Exist: Reward exclusion doesn't prevent balance update");
        }

        // Original validation (to maintain test integrity)
        assertEq(postBurnSupply, 0, "Total supply not zero after burn");
        assertEq(postBurnOwnerBalance, initialSupply, "Owner balance not updated");
        assertGt(postBurnOwnerBalance, postBurnSupply, "Owner balance exceeds total supply");
    }
}