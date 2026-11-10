// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DUZU_Coin.sol";

contract DUZU_CoinTest is Test {
    DUZU_Coin public token;
    address public owner = makeAddr("owner");
    address public user = makeAddr("user");
    uint256 initialSupply = 1000 ether;
    string tokenName = "Test Token";
    string tokenSymbol = "TEST";
    uint8 tokenDecimals = 18;
    address dummyTarget = address(0x123);

    function setUp() public {
        vm.prank(owner);
        token = new DUZU_Coin(
            dummyTarget,
            tokenName,
            tokenSymbol,
            tokenDecimals,
            initialSupply
        );

        // Fund user with tokens
        vm.prank(owner);
        token.transfer(user, 100 ether);
    }

    function testCentralizedTokenRecovery() public {
        // User accidentally sends tokens to token contract
        vm.prank(user);
        token.transfer(address(token), 100 ether);

        // Verify token contract received the tokens
        assertEq(token.balanceOf(address(token)), 100 ether, "Token contract should have tokens");

        console2.log("--- BEFORE-Trigger recoverToken ---");
        uint256 tokenContractBalanceBefore = token.balanceOf(address(token));
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        console2.log("Token contract balance (before):", tokenContractBalanceBefore);
        console2.log("Owner balance (before):", ownerBalanceBefore);

        console2.log("--- Trigger recoverToken ---");
        // Owner recovers tokens without user consent
        vm.prank(owner);
        token.recoverToken(address(token), 100 ether);
        
        console2.log("--- AFTER-Trigger recoverToken ---");
        uint256 tokenContractBalanceAfter = token.balanceOf(address(token));
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        console2.log("Token contract balance (after):", tokenContractBalanceAfter);
        console2.log("Owner balance (after):", ownerBalanceAfter);

        // Verify tokens were moved to owner
        assertEq(token.balanceOf(owner), initialSupply, "Owner should have recovered the tokens");
        assertEq(token.balanceOf(address(token)), 0, "Token contract balance should be zero");

        // Check differential state
        bool tokenContractBalanceDecreased = tokenContractBalanceAfter == 0;
        bool ownerBalanceIncreased = ownerBalanceAfter == ownerBalanceBefore + tokenContractBalanceBefore;
        
        if (tokenContractBalanceDecreased && ownerBalanceIncreased) {
            console2.log("Vulnerability confirmed: Owner successfully recovered tokens without consent");
            console2.log("Vulnerability Exists: Owner can steal user tokens via recoverToken()");
        } else {
            console2.log("State change not as expected, vulnerability not triggered");
            console2.log("Vulnerability not Exist: recoverToken() failed to transfer tokens");
        }
    }
}