// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Ovencoin.sol";

contract OvencoinMintTest is Test {
    Ovencoin public token;
    address public owner = address(0xABCD);
    address public normalUser = address(0x1234);
    uint256 public constant MINT_AMOUNT = 5000 * 1e18;

    function setUp() public {
        // Deploy token as owner
        vm.startPrank(owner);
        token = new Ovencoin();
        vm.stopPrank();
    }

    function test_ownerCanMintTokens() public {
        uint256 initialTotalSupply = token.totalSupply();
        uint256 initialOwnerBalance = token.balanceOf(owner);

        // Owner mints tokens
        vm.prank(owner);
        token.mint(MINT_AMOUNT);

        // Verify token creation
        assertEq(token.totalSupply(), initialTotalSupply + MINT_AMOUNT, "Total supply not increased");
        assertEq(token.balanceOf(owner), initialOwnerBalance + MINT_AMOUNT, "Owner balance not increased");
    }

    function test_nonOwnerCannotMint() public {
        // Non-owner should fail to mint
        vm.prank(normalUser);
        vm.expectRevert("Ownable: caller is not the owner");
        token.mint(MINT_AMOUNT);
    }

    function test_ownerCanCauseHyperinflation() public {
        // Measure initial token balance and supply
        uint256 initialSupply = token.totalSupply();
        uint256 initialOwnerBalance = token.balanceOf(owner);

        console.log("--- BEFORE-Trigger Hyperinflation ---");
        console.log("Initial Total Supply: %s", initialSupply);
        console.log("Initial Owner Balance: %s", initialOwnerBalance);

        // Mint massively to create hyperinflation
        uint256 massiveMint = 100_000_000 * 1e18; // Fixed massive amount
        
        console.log("--- TRIGGER: Owner Mint Massive Tokens ---");
        vm.prank(owner);
        token.mint(massiveMint);

        console.log("--- AFTER-Trigger Hyperinflation ---");
        uint256 newSupply = token.totalSupply();
        uint256 newOwnerBalance = token.balanceOf(owner);
        console.log("New Total Supply: %s", newSupply);
        console.log("New Owner Balance: %s", newOwnerBalance);

        // Verify hyperinflation effects
        uint256 supplyDelta = newSupply - initialSupply;
        uint256 ownerBalanceDelta = newOwnerBalance - initialOwnerBalance;
        console.log("Total Supply Increase: %s", supplyDelta);
        console.log("Owner Balance Increase: %s", ownerBalanceDelta);
        
        // Differential state comparison
        bool exploitationSuccess = (supplyDelta == massiveMint) && 
                                  (ownerBalanceDelta == massiveMint);
        
        // Final vulnerability verdict
        if (exploitationSuccess) {
            console.log("Vulnerability Exists: Owner successfully created hyperinflation via arbitrary minting");
        } else {
            console.log("Vulnerability not Exist: Minting operation failed to properly update state");
        }

        // Execute test assertions (original logic)
        assertEq(token.totalSupply(), initialSupply + massiveMint, "Total supply incorrect after hyperinflation");
        assertEq(token.balanceOf(owner), initialOwnerBalance + massiveMint, "Owner balance incorrect after hyperinflation");
    }
}