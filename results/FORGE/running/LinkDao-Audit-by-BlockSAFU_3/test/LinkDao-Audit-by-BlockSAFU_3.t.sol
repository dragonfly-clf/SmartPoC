// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LINKDAO_Token.sol";

contract LKDTokenTest is Test {
    LINKDAO_Token token;
    address deployer = address(this);

    function setUp() public {
        token = new LINKDAO_Token();
    }

    function test_OwnerCanMintBeyondLimit() public {
        console.log("--- BEFORE-Trigger Mint ---");
        // Capture initial state
        uint256 initialSupply = token.totalSupply();
        uint256 maxSupply = token.maxSupply();
        console.log("Initial totalSupply:", initialSupply);
        console.log("Max supply:", maxSupply);

        // Verify initial conditions
        assertEq(initialSupply, token.preMineSupply(), "Initial supply != preMineSupply");
        assertEq(maxSupply, token.preMineSupply(), "Max supply != preMineSupply");

        console.log("--- Trigger Mint Attempt ---");
        // Attempt to mint beyond max supply (vulnerability trigger)
        bool mintResult = token.mint(1 ether);
        console.log("Mint function return value:", mintResult);

        console.log("--- AFTER-Trigger Mint ---");
        // Capture post-mint state
        uint256 newSupply = token.totalSupply();
        console.log("New totalSupply:", newSupply);
        console.log("State difference (new - initial):", newSupply - initialSupply);

        // Verify supply didn't increase beyond max
        assertEq(newSupply, initialSupply, "Total supply increased beyond max");

        // Final vulnerability verdict
        if (mintResult == true && newSupply == initialSupply) {
            console.log("Vulnerability Exists: Mint function returns success true even when minting exceeds max supply");
        } else {
            console.log("Vulnerability not Exist: Mint function behaves correctly with max supply limits");
        }
    }
}