// SPDX-License-Identifier: MIT
pragma solidity 0.6.2;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BCPToken.sol";

contract BCPTokenMintTest is Test {
    BCPToken token;
    address owner = address(0x1);
    uint256 constant CAP = 1000 * 10**18; // 1000 tokens with 18 decimals

    function setUp() public {
        vm.startPrank(owner);
        token = new BCPToken("BCPToken", "BCP", CAP);
        vm.stopPrank();
    }

    function test_OwnerCanMintEntireSupply() public {
        console.log("--- BEFORE-Trigger Mint ---");
        uint256 supplyBefore = token.totalSupply();
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        console.log("Initial total supply:", supplyBefore);
        console.log("Owner initial balance:", ownerBalanceBefore);

        console.log("--- Trigger Mint ---");
        vm.prank(owner);
        token.mint(owner, CAP);
        console.log("Minted", CAP / 10**18, "tokens to owner");

        console.log("--- AFTER-Trigger Mint ---");
        uint256 supplyAfter = token.totalSupply();
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        console.log("New total supply:", supplyAfter);
        console.log("New owner balance:", ownerBalanceAfter);

        uint256 supplyChange = supplyAfter - supplyBefore;
        uint256 balanceChange = ownerBalanceAfter - ownerBalanceBefore;
        console.log("Supply increase:", supplyChange);
        console.log("Balance increase:", balanceChange);

        if (supplyChange == CAP && balanceChange == CAP) {
            console.log("Vulnerability Exists: Owner can mint entire token supply exceeding contract constraints");
        } else {
            console.log("Vulnerability not Exist: Supply cap enforced");
        }
    }
}