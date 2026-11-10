// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/console2.sol";
import "forge-std/Test.sol";
import "../src/hoop.sol";

contract PrimalHoopTest is Test {
    PrimalHoop token;
    uint256 constant MAX_SUPPLY = 350_000_000 * 1e18; // Updated to match contract's 350M max supply
    address owner = address(0x1);

    function setUp() public {
        vm.startPrank(owner);
        token = new PrimalHoop();
        vm.stopPrank();
    }

    function testMintUpToMaxSupply() public {
        console2.log("--- BEFORE-Trigger Mint ---");
        uint256 preSupply = token.totalSupply();
        console2.log("Initial total supply:", preSupply);
        assertEq(preSupply, 0, "Initial supply not zero"); // Fixed assertion

        console2.log("--- Trigger Mint (Max Supply) ---");
        vm.prank(owner);
        token.mint(owner, MAX_SUPPLY);

        console2.log("--- AFTER-Trigger Mint ---");
        uint256 postSupply = token.totalSupply();
        console2.log("Final total supply:", postSupply);
        uint256 mintedAmount = postSupply - preSupply;
        console2.log("Minted amount:", mintedAmount);
        console2.log("Expected max supply:", MAX_SUPPLY);

        if (postSupply == MAX_SUPPLY) {
            console2.log("Vulnerability not Exist: Correctly minted max supply");
        } else {
            console2.log("Vulnerability Exist: Unexpected mint result");
        }
        assertEq(postSupply, MAX_SUPPLY, "Total supply should reach max supply");
    }

    function testMintBeyondMaxSupplyReverts() public {
        console2.log("--- Initial Mint to MAX_SUPPLY ---");
        vm.prank(owner);
        token.mint(owner, MAX_SUPPLY);
        uint256 postMaxSupply = token.totalSupply();
        assertEq(postMaxSupply, MAX_SUPPLY, "Should be at max supply");

        console2.log("--- BEFORE-Trigger Mint (Beyond Max) ---");
        uint256 preMintSupply = token.totalSupply();
        console2.log("Total supply before additional mint:", preMintSupply);

        console2.log("--- Trigger Mint (Beyond Max - Should Revert) ---");
        vm.prank(owner);
        vm.expectRevert("Total supply higher than max supply.");
        token.mint(owner, 1);

        console2.log("--- AFTER-Trigger Mint ---");
        uint256 postMintSupply = token.totalSupply();
        console2.log("Total supply after mint attempt:", postMintSupply);

        if (postMintSupply > preMintSupply) {
            console2.log("Vulnerability Exists: Successfully minted beyond max supply");
        } else {
            console2.log("Vulnerability not Exist: Minting beyond max supply correctly prevented");
        }
    }
}