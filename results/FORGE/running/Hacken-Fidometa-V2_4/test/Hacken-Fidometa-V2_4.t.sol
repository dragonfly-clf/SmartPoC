// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FidoMeta.sol";

contract FidoMetaMintBurnTest is Test {
    Fidometa token;
    address deployer;
    address constant user1 = address(0x123);
    address constant user2 = address(0x456);
    
    uint256 constant INITIAL_SUPPLY = 15e18;
    uint256 constant SETUP_BURN = 10e18;
    uint256 constant USER_SHARE = 1e18;
    uint256 constant MINT_AMOUNT = 5e18;
    uint256 constant BURN_AMOUNT = 1e18;

    function setUp() public {
        deployer = address(this);
        token = new Fidometa();
    }

    function test_MintChangesUserBalances() public {
        // Setup
        token.burn(SETUP_BURN);
        token.transfer(user1, USER_SHARE);
        token.transfer(user2, USER_SHARE);

        console.log("--- BEFORE-Trigger Mint Operation ---");
        uint256 oldTotalSupply = token.totalSupply();
        uint256 oldBalanceUser1 = token.balanceOf(user1);
        uint256 oldBalanceUser2 = token.balanceOf(user2);
        console.log("Total Supply:", oldTotalSupply);
        console.log("User1 Balance:", oldBalanceUser1);
        console.log("User2 Balance:", oldBalanceUser2);

        console.log("--- Trigger Mint Operation ---");
        token.mint(MINT_AMOUNT);
        console.log("Minted amount: %d", MINT_AMOUNT);

        console.log("--- AFTER-Trigger Mint Operation ---");
        uint256 newTotalSupply = token.totalSupply();
        uint256 newBalanceUser1 = token.balanceOf(user1);
        uint256 newBalanceUser2 = token.balanceOf(user2);
        console.log("Total Supply:", newTotalSupply);
        console.log("User1 Balance:", newBalanceUser1);
        console.log("User2 Balance:", newBalanceUser2);

        // Differential validation
        bool user1Changed = (oldBalanceUser1 != newBalanceUser1);
        bool user2Changed = (oldBalanceUser2 != newBalanceUser2);
        if(user1Changed || user2Changed) {
            console.log("Vulnerability Exists: user balances changed during mint");
        } else {
            console.log("Vulnerability not Exist: user balances unchanged during mint");
        }

        // Original test assertions
        assertTrue(user1Changed, "User1 balance unchanged after mint");
        assertTrue(user2Changed, "User2 balance unchanged after mint");
    }

    function test_BurnChangesUserBalances() public {
        // Setup
        token.burn(SETUP_BURN);
        token.transfer(user1, USER_SHARE);
        token.transfer(user2, USER_SHARE);

        console.log("--- BEFORE-Trigger Burn Operation ---");
        uint256 oldTotalSupply = token.totalSupply();
        uint256 oldBalanceUser1 = token.balanceOf(user1);
        uint256 oldBalanceUser2 = token.balanceOf(user2);
        console.log("Total Supply:", oldTotalSupply);
        console.log("User1 Balance:", oldBalanceUser1);
        console.log("User2 Balance:", oldBalanceUser2);

        console.log("--- Trigger Burn Operation ---");
        token.burn(BURN_AMOUNT);
        console.log("Burned amount: %d", BURN_AMOUNT);

        console.log("--- AFTER-Trigger Burn Operation ---");
        uint256 newTotalSupply = token.totalSupply();
        uint256 newBalanceUser1 = token.balanceOf(user1);
        uint256 newBalanceUser2 = token.balanceOf(user2);
        console.log("Total Supply:", newTotalSupply);
        console.log("User1 Balance:", newBalanceUser1);
        console.log("User2 Balance:", newBalanceUser2);

        // Differential validation
        bool user1Changed = (oldBalanceUser1 != newBalanceUser1);
        bool user2Changed = (oldBalanceUser2 != newBalanceUser2);
        if(user1Changed || user2Changed) {
            console.log("Vulnerability Exists: user balances changed during burn");
        } else {
            console.log("Vulnerability not Exist: user balances unchanged during burn");
        }

        // Original test assertions
        assertTrue(user1Changed, "User1 balance unchanged after burn");
        assertTrue(user2Changed, "User2 balance unchanged after burn");
    }
}