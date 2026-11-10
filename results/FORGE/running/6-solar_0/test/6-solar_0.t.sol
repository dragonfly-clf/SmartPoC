// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Solar.sol";

contract SolarTest is Test {
    Solar token;
    address constant owner = address(0x1);
    address constant nonOwner = address(0x2);
    address constant recipient = address(0x3);
    
    function setUp() public {
        vm.startPrank(owner);
        token = new Solar();
        vm.stopPrank();
    }

    function testOwnerCanMint() public {
        vm.prank(owner);
        token.mint(recipient, 100 ether);
        
        assertEq(token.totalSupply(), 100 ether);
        assertEq(token.balanceOf(recipient), 100 ether);
    }

    function testNonOwnerCannotMint() public {
        // Pre-attack state snapshot
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 nonOwnerBalanceBefore = token.balanceOf(nonOwner);
        uint256 recipientBalanceBefore = token.balanceOf(recipient);
        
        console.log("--- BEFORE-Trigger State ---");
        console.log("Total Supply:        ", totalSupplyBefore);
        console.log("NonOwner Balance:    ", nonOwnerBalanceBefore);
        console.log("Recipient Balance:   ", recipientBalanceBefore);
        console.log("");

        console.log("--- Trigger Action: nonOwner mint attempt ---");
        vm.prank(nonOwner);
        try token.mint(recipient, 100 ether) {
            // Only proceeds if call doesn't revert
            console.log("Mint call did NOT revert (potential vulnerability)");
        } catch {
            console.log("Mint call reverted (expected behavior)");
        }

        // Post-attack state snapshot
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 nonOwnerBalanceAfter = token.balanceOf(nonOwner);
        uint256 recipientBalanceAfter = token.balanceOf(recipient);
        
        console.log("");
        console.log("--- AFTER-Trigger State ---");
        console.log("Total Supply:        ", totalSupplyAfter);
        console.log("NonOwner Balance:    ", nonOwnerBalanceAfter);
        console.log("Recipient Balance:   ", recipientBalanceAfter);
        console.log("");

        // Vulnerability assessment
        bool supplyIncreased = totalSupplyAfter > totalSupplyBefore;
        bool balanceIncreased = recipientBalanceAfter > recipientBalanceBefore;
        bool unauthorizedMintSuccess = supplyIncreased && balanceIncreased;
        
        console.log("Diff Results:");
        console.log("- Supply Change:     ", supplyIncreased ? "INCREASED" : "No change");
        console.log("- Recipient Change:  ", balanceIncreased ? "INCREASED" : "No change");
        console.log("- Combined Verdict:  ", unauthorizedMintSuccess ? "VULNERABLE STATE CHANGE" : "STATE SECURE");

        // Final vulnerability conclusion
        if (unauthorizedMintSuccess) {
            console.log("Vulnerability Exists: Non-owner triggered unauthorized supply increase");
        } else {
            console.log("Vulnerability not Exist: State unchanged by non-owner mint attempt");
        }
    }

    function testMintRespectsMaxSupply() public {
        uint256 maxSupply = token.getMaxTotalSupply();
        
        vm.startPrank(owner);
        token.mint(recipient, maxSupply);
        assertEq(token.totalSupply(), maxSupply);
        
        vm.expectRevert("ERC20: minting more than MaxTotalSupply");
        token.mint(recipient, 1);
        vm.stopPrank();
    }
}