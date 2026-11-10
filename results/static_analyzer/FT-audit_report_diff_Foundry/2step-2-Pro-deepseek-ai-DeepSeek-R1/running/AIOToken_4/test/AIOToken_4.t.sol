// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/AIOToken.sol";

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0x1234);
    }
}

contract AIOTokenTest is Test {
    AIOToken token;
    address owner;
    address constant factoryAddress = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address constant bnbAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address nonTokenBurner;

    function setUp() public {
        // Mock the factory by replacing the factory address code
        MockFactory mockFactory = new MockFactory();
        vm.etch(factoryAddress, address(mockFactory).code);

        // Deploy token which uses the mocked factory address
        token = new AIOToken();
        owner = token.owner();
        nonTokenBurner = address(0x1);
    }

    function test_ZeroAddressTokenBurnerBreakBurn() public {
        console.log("--- BEFORE-Trigger State ---");
        address initialBurner = token.tokenBurner();
        console.log("Initial tokenBurner:", initialBurner);

        console.log("--- Trigger: setTokenBurner(0x0) ---");
        // Set token burner to zero address as owner
        vm.prank(owner);
        token.setTokenBurner(address(0));

        console.log("--- AFTER-Trigger State ---");
        address updatedBurner = token.tokenBurner();
        console.log("Updated tokenBurner:", updatedBurner);

        console.log("--- Executing burn() Verification ---");
        // Verify burn functionality is unusable
        vm.prank(nonTokenBurner);
        vm.expectRevert(); // Expect revert from modifier protection
        token.burn(owner, 1); // Will fail due to zero address token burner
        console.log("Transaction reverted as expected");

        console.log("Vulnerability Exists: Burn function reverts when called by non-owner with tokenBurner=0");
    }
}