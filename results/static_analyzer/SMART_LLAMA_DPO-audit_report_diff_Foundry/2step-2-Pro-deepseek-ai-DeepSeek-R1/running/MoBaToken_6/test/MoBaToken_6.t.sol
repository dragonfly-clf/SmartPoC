// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MoBaToken.sol";

contract MoBaTokenTest is Test {
    MoBaToken token;
    address owner = vm.addr(1);
    address user = vm.addr(2);

    function setUp() public {
        vm.prank(owner);
        token = new MoBaToken("TestToken", "TT");
    }

    function test_owner_can_mint_arbitrarily() public {
        uint256 mintAmount = 100 ether;

        console.log("--- BEFORE-Trigger (Mint) ---");
        uint256 beforeBalance = token.balanceOf(user);
        console.log("User balance before mint:", beforeBalance);

        console.log("--- Trigger: Mint Operation ---");
        vm.prank(owner);
        token.cross(user, mintAmount);

        console.log("--- AFTER-Trigger (Mint) ---");
        uint256 afterBalance = token.balanceOf(user);
        console.log("User balance after mint:", afterBalance);

        if (afterBalance == beforeBalance + mintAmount) {
            console.log("Vulnerability Exists: Owner can arbitrarily mint tokens");
        } else {
            console.log("Vulnerability not Exist: Mint operation failed or didn't change balance as expected");
        }
    }

    function test_owner_can_burn_arbitrarily() public {
        uint256 mintAmount = 100 ether;
        uint256 burnAmount = 50 ether;

        // Setup mint
        vm.prank(owner);
        token.cross(user, mintAmount);

        console.log("--- BEFORE-Trigger (Burn) ---");
        uint256 beforeBalance = token.balanceOf(user);
        console.log("User balance before burn:", beforeBalance);

        console.log("--- Trigger: Burn Operation ---");
        vm.prank(owner);
        token.managerBurn(user, burnAmount);

        console.log("--- AFTER-Trigger (Burn) ---");
        uint256 afterBalance = token.balanceOf(user);
        console.log("User balance after burn:", afterBalance);

        if (afterBalance == beforeBalance - burnAmount) {
            console.log("Vulnerability Exists: Owner can arbitrarily burn user tokens");
        } else {
            console.log("Vulnerability not Exist: Burn operation failed or didn't change balance as expected");
        }
    }
}