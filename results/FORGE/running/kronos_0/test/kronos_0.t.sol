// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KronosDaoToken.sol";

contract MockAntiBot {
    function setTokenOwner(address) external {
        // No operation needed for test
    }
}

contract TokenTest is Test {
    KronosDaoToken token;
    MockAntiBot mockAntiBot;
    address owner = address(0xABCD);
    address vault = address(0x1234);
    address user = address(0x5678);
    uint256 constant MINT_AMOUNT = 1_000_000 * 1e9;

    function setUp() public {
        vm.startPrank(owner);
        mockAntiBot = new MockAntiBot();
        token = new KronosDaoToken(address(mockAntiBot));
        token.setVault(vault);
        vm.stopPrank();
    }

    function testUnlimitedMinting() public {
        vm.startPrank(vault);
        uint256 initialSupply = token.totalSupply();
        
        // First mint: to vault
        console.log("--- BEFORE-Trigger Mint (to vault) ---");
        uint256 totalSupplyBeforeVault = token.totalSupply();
        uint256 vaultBalanceBeforeVault = token.balanceOf(vault);
        console.log("Total supply before:", totalSupplyBeforeVault);
        console.log("Vault balance before:", vaultBalanceBeforeVault);
        
        console.log("--- Trigger Mint: vault mint to itself ---");
        token.mint(vault, MINT_AMOUNT);
        
        console.log("--- AFTER-Trigger Mint (to vault) ---");
        uint256 totalSupplyAfterVault = token.totalSupply();
        uint256 vaultBalanceAfterVault = token.balanceOf(vault);
        console.log("Total supply after:", totalSupplyAfterVault);
        console.log("Vault balance after:", vaultBalanceAfterVault);
        
        uint256 supplyDifferenceVault = totalSupplyAfterVault - totalSupplyBeforeVault;
        uint256 balanceDifferenceVault = vaultBalanceAfterVault - vaultBalanceBeforeVault;
        console.log("Supply increase (vault mint):", supplyDifferenceVault);
        console.log("Vault balance increase (vault mint):", balanceDifferenceVault);
        
        bool vaultMintSucceeded = (supplyDifferenceVault == MINT_AMOUNT) && 
                                  (balanceDifferenceVault == MINT_AMOUNT);
        console.log("Mint to vault successful:", vaultMintSucceeded ? "YES" : "NO");
        
        // Second mint: to user
        console.log("--- BEFORE-Trigger Mint (to user) ---");
        uint256 totalSupplyBeforeUser = token.totalSupply();
        uint256 userBalanceBeforeUser = token.balanceOf(user);
        console.log("Total supply before:", totalSupplyBeforeUser);
        console.log("User balance before:", userBalanceBeforeUser);
        
        console.log("--- Trigger Mint: vault mint to user ---");
        token.mint(user, MINT_AMOUNT);
        
        console.log("--- AFTER-Trigger Mint (to user) ---");
        uint256 totalSupplyAfterUser = token.totalSupply();
        uint256 userBalanceAfterUser = token.balanceOf(user);
        console.log("Total supply after:", totalSupplyAfterUser);
        console.log("User balance after:", userBalanceAfterUser);
        
        uint256 supplyDifferenceUser = totalSupplyAfterUser - totalSupplyBeforeUser;
        uint256 balanceDifferenceUser = userBalanceAfterUser - userBalanceBeforeUser;
        console.log("Supply increase (user mint):", supplyDifferenceUser);
        console.log("User balance increase:", balanceDifferenceUser);
        
        bool userMintSucceeded = (supplyDifferenceUser == MINT_AMOUNT) && 
                                 (balanceDifferenceUser == MINT_AMOUNT);
        console.log("Mint to user successful:", userMintSucceeded ? "YES" : "NO");
        
        // Final verdict
        if (vaultMintSucceeded && userMintSucceeded) {
            console.log("Vulnerability Exists: Vault can mint tokens arbitrarily without restrictions.");
        } else {
            console.log("Vulnerability not Exist: Minting restrictions are effective.");
        }
        
        assertTrue(
            vaultMintSucceeded && userMintSucceeded, 
            "Unrestricted minting by vault failed"
        );
    }
    
    function testVaultPrivileges() public {
        // Non-vault address shouldn't be able to mint
        vm.expectRevert("VaultOwned: caller is not the Vault");
        vm.prank(user);
        token.mint(user, MINT_AMOUNT);
    }
}