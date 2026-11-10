// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract CoinTokenMintTest is Test {
    CoinToken token;
    address owner = makeAddr("owner");
    address user = makeAddr("user");
    uint8 constant DECIMALS = 18;
    uint256 constant INITIAL_SUPPLY = 1000000 * (10 ** 18);
    uint256 constant MINT_AMOUNT = 2000000 * (10 ** 18);
    address payable constant FEE_RECEIVER = payable(address(0));

    function setUp() public {
        // Start prank as owner to deploy contract
        vm.startPrank(owner);
        token = new CoinToken{value: 0}(
            "VulnerableToken", 
            "VULN", 
            DECIMALS, 
            1000000,   // initialBalance_
            owner, 
            FEE_RECEIVER
        );
        vm.stopPrank();
    }

    function test_owner_can_mint_arbitrarily() public {
        console.log("--- BEFORE-Trigger State ---");
        // Record initial token metrics
        uint256 initialSupply = token.totalSupply();
        uint256 initialOwnerBalance = token.balanceOf(owner);
        console.log("Initial total supply:", initialSupply);
        console.log("Initial owner balance:", initialOwnerBalance);
        console.log("Mint amount planned:", MINT_AMOUNT);

        console.log("--- Trigger Mint ---");
        // Owner mints new tokens
        vm.prank(owner);
        token.mint(owner, MINT_AMOUNT);

        console.log("--- AFTER-Trigger State ---");
        uint256 newSupply = token.totalSupply();
        uint256 newOwnerBalance = token.balanceOf(owner);
        console.log("New total supply:", newSupply);
        console.log("New owner balance:", newOwnerBalance);

        uint256 supplyDiff = newSupply - initialSupply;
        uint256 balanceDiff = newOwnerBalance - initialOwnerBalance;
        console.log("Total supply increase:", supplyDiff);
        console.log("Owner balance increase:", balanceDiff);

        if (supplyDiff == MINT_AMOUNT && balanceDiff == MINT_AMOUNT) {
            console.log("Vulnerability Exists: Owner can mint arbitrarily, causing the total supply and owner balance to increase by the mint amount");
        } else {
            console.log("Vulnerability not Exist: The mint operation did not change the state as expected");
        }

        // Verify token inflation
        assertEq(
            newSupply, 
            initialSupply + MINT_AMOUNT, 
            "Total supply not increased"
        );
        assertEq(
            newOwnerBalance, 
            initialOwnerBalance + MINT_AMOUNT, 
            "Owner balance not increased"
        );
    }

    function test_non_owner_cannot_mint() public {
        // Confirm non-owner cannot mint
        vm.prank(user);
        vm.expectRevert("Ownable: caller is not the owner");
        token.mint(user, MINT_AMOUNT);

        // Verify no supply change
        assertEq(token.totalSupply(), INITIAL_SUPPLY, "Supply changed unexpectedly");
    }

    function test_permanent_solution_renounce_ownership() public {
        // Owner renounces ownership
        vm.prank(owner);
        token.renounceOwnership();
        
        // Verify minting disabled after ownership renounced
        vm.prank(owner);
        vm.expectRevert("Ownable: caller is not the owner");
        token.mint(owner, MINT_AMOUNT);
    }
}