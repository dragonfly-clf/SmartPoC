// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/hoop.sol";

contract PrimalHoopMintTest is Test {
    PrimalHoop token;
    address owner;
    address recipient = address(0xF1A7);
    uint256 constant MAX_SUPPLY = 350_000_000 * 10**18; // 350 million tokens with 18 decimals

    function setUp() public {
        owner = address(this);
        token = new PrimalHoop();
    }

    function test_MintToZeroAddressReverts() public {
        uint256 mintAmount = 100;

        // Before snapshot
        console.log("--- BEFORE-Trigger MintToZeroAddress ---");
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 recipientBalanceBefore = token.balanceOf(recipient);
        uint256 zeroAddrBalanceBefore = token.balanceOf(address(0));
        console.log("Total Supply Before:", totalSupplyBefore);
        console.log("Owner Balance Before:", ownerBalanceBefore);
        console.log("Recipient Balance Before:", recipientBalanceBefore);
        console.log("Zero Address Balance Before:", zeroAddrBalanceBefore);

        // Trigger action
        console.log("--- Trigger MintToZeroAddress ---");
        vm.prank(owner);
        vm.expectRevert("ERC20: mint to the zero address");
        token.mint(address(0), mintAmount);

        // After snapshot
        console.log("--- AFTER-Trigger MintToZeroAddress ---");
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        uint256 recipientBalanceAfter = token.balanceOf(recipient);
        uint256 zeroAddrBalanceAfter = token.balanceOf(address(0));
        console.log("Total Supply After:", totalSupplyAfter);
        console.log("Owner Balance After:", ownerBalanceAfter);
        console.log("Recipient Balance After:", recipientBalanceAfter);
        console.log("Zero Address Balance After:", zeroAddrBalanceAfter);

        // Validation
        bool stateUnchanged = (totalSupplyBefore == totalSupplyAfter) &&
                             (ownerBalanceBefore == ownerBalanceAfter) &&
                             (recipientBalanceBefore == recipientBalanceAfter) &&
                             (zeroAddrBalanceBefore == zeroAddrBalanceAfter);
                             
        if (stateUnchanged) {
            console.log("Vulnerability not Exist: State remains unchanged after reverting mint");
        } else {
            console.log("Vulnerability Exists: State modified during reverted mint operation");
        }
    }

    function test_MintExceedsMaxSupplyReverts() public {
        vm.startPrank(owner);
        
        // First mint (valid) - fill to max capacity
        token.mint(recipient, MAX_SUPPLY);
        
        // Before snapshot
        console.log("--- BEFORE-Trigger MintExceedsMaxSupply ---");
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 recipientBalanceBefore = token.balanceOf(recipient);
        uint256 zeroAddrBalanceBefore = token.balanceOf(address(0));
        console.log("Total Supply Before:", totalSupplyBefore);
        console.log("Owner Balance Before:", ownerBalanceBefore);
        console.log("Recipient Balance Before:", recipientBalanceBefore);
        console.log("Zero Address Balance Before:", zeroAddrBalanceBefore);

        // Trigger action
        console.log("--- Trigger MintExceedsMaxSupply ---");
        vm.expectRevert("Total supply higher than max supply.");
        token.mint(recipient, 1);  // 1 wei exceeds limit
        
        // After snapshot
        console.log("--- AFTER-Trigger MintExceedsMaxSupply ---");
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        uint256 recipientBalanceAfter = token.balanceOf(recipient);
        uint256 zeroAddrBalanceAfter = token.balanceOf(address(0));
        console.log("Total Supply After:", totalSupplyAfter);
        console.log("Owner Balance After:", ownerBalanceAfter);
        console.log("Recipient Balance After:", recipientBalanceAfter);
        console.log("Zero Address Balance After:", zeroAddrBalanceAfter);
        
        // Validation
        bool stateUnchanged = (totalSupplyBefore == totalSupplyAfter) &&
                             (ownerBalanceBefore == ownerBalanceAfter) &&
                             (recipientBalanceBefore == recipientBalanceAfter) &&
                             (zeroAddrBalanceBefore == zeroAddrBalanceAfter);
        
        vm.stopPrank();
                             
        if (stateUnchanged) {
            console.log("Vulnerability not Exist: State remains unchanged after exceeding supply limit");
        } else {
            console.log("Vulnerability Exists: State modified during reverted overflow mint");
        }
    }

    function test_MintBeyondSupplyInSingleTxReverts() public {
        // Before snapshot
        console.log("--- BEFORE-Trigger MintBeyondSupply ---");
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 recipientBalanceBefore = token.balanceOf(recipient);
        uint256 zeroAddrBalanceBefore = token.balanceOf(address(0));
        console.log("Total Supply Before:", totalSupplyBefore);
        console.log("Owner Balance Before:", ownerBalanceBefore);
        console.log("Recipient Balance Before:", recipientBalanceBefore);
        console.log("Zero Address Balance Before:", zeroAddrBalanceBefore);

        // Trigger action
        console.log("--- Trigger MintBeyondSupply ---");
        vm.prank(owner);
        vm.expectRevert("Total supply higher than max supply.");
        token.mint(owner, MAX_SUPPLY + 1);  // Single tx exceeding max

        // After snapshot
        console.log("--- AFTER-Trigger MintBeyondSupply ---");
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        uint256 recipientBalanceAfter = token.balanceOf(recipient);
        uint256 zeroAddrBalanceAfter = token.balanceOf(address(0));
        console.log("Total Supply After:", totalSupplyAfter);
        console.log("Owner Balance After:", ownerBalanceAfter);
        console.log("Recipient Balance After:", recipientBalanceAfter);
        console.log("Zero Address Balance After:", zeroAddrBalanceAfter);

        // Validation
        bool stateUnchanged = (totalSupplyBefore == totalSupplyAfter) &&
                             (ownerBalanceBefore == ownerBalanceAfter) &&
                             (recipientBalanceBefore == recipientBalanceAfter) &&
                             (zeroAddrBalanceBefore == zeroAddrBalanceAfter);
                             
        if (stateUnchanged) {
            console.log("Vulnerability not Exist: State remains unchanged after invalid mint");
        } else {
            console.log("Vulnerability Exists: State modified during single-tx overflow mint");
        }
    }

    function test_ownerCanSelfMint() public {
        uint256 mintAmount = 1_000 * 10**18;
        
        // Before snapshot
        console.log("--- BEFORE-Trigger OwnerSelfMint ---");
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 recipientBalanceBefore = token.balanceOf(recipient);
        uint256 zeroAddrBalanceBefore = token.balanceOf(address(0));
        console.log("Total Supply Before:", totalSupplyBefore);
        console.log("Owner Balance Before:", ownerBalanceBefore);
        console.log("Recipient Balance Before:", recipientBalanceBefore);
        console.log("Zero Address Balance Before:", zeroAddrBalanceBefore);

        // Trigger action
        console.log("--- Trigger OwnerSelfMint ---");
        vm.prank(owner);
        token.mint(owner, mintAmount);
        
        // After snapshot
        console.log("--- AFTER-Trigger OwnerSelfMint ---");
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        uint256 recipientBalanceAfter = token.balanceOf(recipient);
        uint256 zeroAddrBalanceAfter = token.balanceOf(address(0));
        console.log("Total Supply After:", totalSupplyAfter);
        console.log("Owner Balance After:", ownerBalanceAfter);
        console.log("Recipient Balance After:", recipientBalanceAfter);
        console.log("Zero Address Balance After:", zeroAddrBalanceAfter);

        // Validation
        bool stateChangedCorrectly = (totalSupplyAfter == totalSupplyBefore + mintAmount) &&
                                    (ownerBalanceAfter == ownerBalanceBefore + mintAmount) &&
                                    (recipientBalanceAfter == recipientBalanceBefore) &&
                                    (zeroAddrBalanceAfter == zeroAddrBalanceBefore);
        
        if (stateChangedCorrectly) {
            console.log("Vulnerability not Exist: State changed as expected for valid mint");
        } else {
            console.log("Vulnerability Exists: State changed incorrectly during owner mint");
        }

        // Existing assertions
        assertEq(token.balanceOf(owner), mintAmount);
        assertEq(token.totalSupply(), mintAmount);
    }
}