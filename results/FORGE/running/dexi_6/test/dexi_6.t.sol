// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DEXI.sol";

contract DEIXBurnTest is Test {
    DEXI token;
    address owner = address(1);
    address user = address(2);
    address constant BURN_POOL = address(0x000000000000000000000000000000000000dEaD);
    uint256 initialSupply;
    
    function setUp() public {
        vm.startPrank(owner);
        token = new DEXI();
        vm.stopPrank();
        
        initialSupply = token.totalSupply();
        vm.prank(owner);
        token.transfer(user, initialSupply / 2);
    }

    function testBurnBreaksSupplyInvariant() public {
        uint256 burnAmount = token.balanceOf(user) / 2;
        emit log("--- BEFORE-Trigger State ---");
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 userBalanceBefore = token.balanceOf(user);
        uint256 burnPoolBalanceBefore = token.balanceOf(BURN_POOL);
        uint256 sumBalancesBefore = ownerBalanceBefore + userBalanceBefore + burnPoolBalanceBefore;
        
        emit log_named_uint("Total supply before", totalSupplyBefore);
        emit log_named_uint("Sum of balances before", sumBalancesBefore);
        emit log_named_string("Invariant holds before?", 
            totalSupplyBefore == sumBalancesBefore ? "Yes" : "No");
        
        emit log("--- Trigger Burn Operation ---");
        vm.prank(owner);
        token.burn(user, burnAmount);
        emit log_named_uint("Burned amount", burnAmount);
        
        emit log("--- AFTER-Trigger State ---");
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        uint256 userBalanceAfter = token.balanceOf(user);
        uint256 burnPoolBalanceAfter = token.balanceOf(BURN_POOL);
        uint256 sumBalancesAfter = ownerBalanceAfter + userBalanceAfter + burnPoolBalanceAfter;
        
        emit log_named_uint("Total supply after", totalSupplyAfter);
        emit log_named_uint("Sum of balances after", sumBalancesAfter);
        bool invariantBroken = (totalSupplyAfter != sumBalancesAfter);
        
        emit log("--- Differential Verification ---");
        emit log_named_uint("Supply change", totalSupplyBefore - totalSupplyAfter);
        emit log_named_uint("Balance sum change", sumBalancesBefore - sumBalancesAfter);
        emit log_named_string("Invariant after burn broken?", 
            invariantBroken ? "YES" : "NO, vulnerability not exist");
        
        if (invariantBroken) {
            emit log("Vulnerability Exists: Invariant broken (total supply != sum of balances)");
        } else {
            emit log("Vulnerability not Exist: Invariant holds after burn operation");
        }

        // Existing state checks and assertions remain
        assertEq(
            totalSupplyAfter, 
            totalSupplyBefore - burnAmount,
            "Total supply not decreased correctly"
        );
        
        assertEq(
            userBalanceAfter,
            userBalanceBefore - burnAmount,
            "User balance not decreased correctly"
        );
        
        assertEq(
            burnPoolBalanceAfter,
            burnPoolBalanceBefore + burnAmount,
            "Burn pool not received tokens"
        );
        
        assertNotEq(
            ownerBalanceAfter + userBalanceAfter + burnPoolBalanceAfter,
            totalSupplyAfter,
            "Invariant broken: Sum of balances equals total supply"
        );
    }
}