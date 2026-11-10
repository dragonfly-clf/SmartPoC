// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FidoMeta.sol";

contract FidometaBalanceTest is Test {
    Fidometa token;
    address owner = address(0x1);
    uint256 constant TEST_AMOUNT = 1e17;

    function setUp() public {
        vm.prank(owner);
        token = new Fidometa();
    }

    // Test that burning tokens reduces supply but doesn't update user balance
    function testBurnBalanceInconsistency() public {
        console.log("--- BEFORE-Trigger Burn ---");
        uint256 initialSupply = token.totalSupply();
        uint256 initialOwnerBalance = token.balanceOf(owner);
        console.log("Initial total supply: ", initialSupply);
        console.log("Initial owner balance: ", initialOwnerBalance);
        
        require(initialOwnerBalance >= TEST_AMOUNT, "Owner has insufficient tokens for test");

        // Make owner excluded from reward to isolate balance tracking
        vm.prank(owner);
        token.excludeFromReward(owner);

        console.log("--- Trigger Burn ---");
        vm.prank(owner);
        token.burn(TEST_AMOUNT);

        console.log("--- AFTER-Trigger Burn ---");
        uint256 finalSupply = token.totalSupply();
        uint256 finalOwnerBalance = token.balanceOf(owner);
        console.log("Final total supply: ", finalSupply);
        console.log("Final owner balance: ", finalOwnerBalance);
        
        bool supplyReduced = (finalSupply == initialSupply - TEST_AMOUNT);
        bool balanceUnchanged = (finalOwnerBalance == initialOwnerBalance);
        
        if (supplyReduced && balanceUnchanged) {
            console.log("Vulnerability Exists: Total supply reduced correctly, but owner balance remained unchanged");
        } else {
            console.log("Vulnerability not Exist: Either supply didn't reduce or owner balance changed normally");
        }
    }

    // Test that minting increases supply but doesn't update user balance
    function testMintBalanceInconsistency() public {
        uint256 burnAmount = token.cap() / 10;
        vm.prank(owner);
        token.burn(burnAmount);

        console.log("--- BEFORE-Trigger Mint ---");
        uint256 preMintSupply = token.totalSupply();
        uint256 preMintOwnerBalance = token.balanceOf(owner);
        console.log("Pre-mint total supply: ", preMintSupply);
        console.log("Pre-mint owner balance: ", preMintOwnerBalance);

        vm.prank(owner);
        token.excludeFromReward(owner);

        console.log("--- Trigger Mint ---");
        vm.prank(owner);
        token.mint(burnAmount);

        console.log("--- AFTER-Trigger Mint ---");
        uint256 postMintSupply = token.totalSupply();
        uint256 postMintOwnerBalance = token.balanceOf(owner);
        console.log("Post-mint total supply: ", postMintSupply);
        console.log("Post-mint owner balance: ", postMintOwnerBalance);
        
        bool supplyIncreased = (postMintSupply == token.cap());
        bool balanceUnchanged = (postMintOwnerBalance == preMintOwnerBalance);
        
        if (supplyIncreased && balanceUnchanged) {
            console.log("Vulnerability Exists: Total supply increased correctly, but owner balance remained unchanged");
        } else {
            console.log("Vulnerability not Exist: Either supply didn't reach cap or owner balance changed normally");
        }
    }
}