// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/hoop.sol";

contract TestPrimalHoopMint is Test {
    PrimalHoop token;
    address owner = address(0x1);

    function setUp() public {
        vm.prank(owner);
        token = new PrimalHoop();
    }

    function test_MintExceedsMaxSupplyRevertsAfterStateChange() public {
        vm.startPrank(owner);
        
        // Calculate the exact max supply as defined in the contract
        uint256 maxSupply = 350_000_000 * (10 ** token.decimals());
        
        console.log("--- BEFORE-Trigger Mint ---");
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        console.log("Total Supply BEFORE:", totalSupplyBefore);
        console.log("Owner Balance BEFORE:", ownerBalanceBefore);

        console.log("--- Trigger Mint (with Revert Expected) ---");
        vm.expectRevert("Total supply higher than max supply.");
        token.mint(owner, maxSupply + 1);

        console.log("--- AFTER-Trigger Mint ---");
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        console.log("Total Supply AFTER:", totalSupplyAfter);
        console.log("Owner Balance AFTER:", ownerBalanceAfter);

        // Compare state before and after
        bool stateUnchanged = (totalSupplyBefore == totalSupplyAfter) && 
                             (ownerBalanceBefore == ownerBalanceAfter);
        
        console.log("State Unchanged?:", stateUnchanged ? "Yes" : "No");
        
        if (stateUnchanged) {
            console.log("Vulnerability not Exist: Revert occurred and state remains unchanged.");
        } else {
            console.log("Vulnerability Exists: State changed after revert.");
        }

        vm.stopPrank();
    }
}