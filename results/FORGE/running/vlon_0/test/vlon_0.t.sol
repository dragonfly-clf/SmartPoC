// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ValonToken.sol";

contract ValonTokenMintTest is Test {
    ValonToken public token;
    address public owner = address(0xA);
    address public nonOwner = address(0xB);
    uint256 public constant INITIAL_SUPPLY = 1000 ether;
    uint256 public constant MINT_AMOUNT = 5000 ether;

    function setUp() public {
        vm.startPrank(owner);
        token = new ValonToken(INITIAL_SUPPLY);
        vm.stopPrank();
    }

    function test_owner_can_mint_arbitrary_amount() public {
        // Pre-mint state
        uint256 initialTotalSupply = token.totalSupply();
        uint256 initialOwnerBalance = token.balanceOf(owner);

        console.log("--- BEFORE-Trigger Mint ---");
        console.log("Total Supply: %s", initialTotalSupply);
        console.log("Owner Balance: %s", initialOwnerBalance);

        // Mint trigger
        console.log("--- Trigger Mint ---");
        vm.prank(owner);
        token.mint(MINT_AMOUNT);

        // Post-mint state
        uint256 newTotalSupply = token.totalSupply();
        uint256 newOwnerBalance = token.balanceOf(owner);

        console.log("--- AFTER-Trigger Mint ---");
        console.log("Total Supply: %s", newTotalSupply);
        console.log("Owner Balance: %s", newOwnerBalance);

        // State change verification
        bool totalSupplyChanged = newTotalSupply == initialTotalSupply + MINT_AMOUNT;
        bool ownerBalanceChanged = newOwnerBalance == initialOwnerBalance + MINT_AMOUNT;

        console.log("Verification:");
        console.log("Total Supply changed as expected? %s", totalSupplyChanged ? "Yes" : "No");
        console.log("Owner Balance changed as expected? %s", ownerBalanceChanged ? "Yes" : "No");

        if (totalSupplyChanged && ownerBalanceChanged) {
            console.log("Vulnerability Exists: Owner can mint arbitrary tokens without restriction");
        } else {
            console.log("Vulnerability not Exist: Minting function changed state incorrectly or was not called");
        }

        // Original assertions
        assertEq(
            token.totalSupply(),
            initialTotalSupply + MINT_AMOUNT,
            "Total supply not increased correctly"
        );
        assertEq(
            token.balanceOf(owner),
            initialOwnerBalance + MINT_AMOUNT,
            "Owner balance not increased correctly"
        );
    }

    function test_non_owner_cannot_mint() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(nonOwner);
        token.mint(MINT_AMOUNT);
    }

    function test_mint_causes_inflation() public {
        // Get initial inflation rate (should be 1:1)
        uint256 initialInflationRate = token.balanceOf(owner) * 1000 / token.totalSupply();
        
        vm.prank(owner);
        token.mint(MINT_AMOUNT);
        
        // Calculate new inflation rate
        uint256 newInflationRate = token.balanceOf(owner) * 1000 / token.totalSupply();
        
        // Inflation rate should stay the same since owner mints to themselves
        assertEq(
            initialInflationRate, 
            newInflationRate, 
            "Inflation distribution changed unexpectedly"
        );

        // Verify supply inflation occurred
        assertGt(
            token.totalSupply(),
            INITIAL_SUPPLY,
            "Token supply inflation not occurred"
        );
    }
}