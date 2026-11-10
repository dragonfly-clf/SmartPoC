// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DeHealthToken.sol";

contract DeHealthTokenTest is Test {
    DeHealthToken token;
    address admin = address(0x1000);
    address attacker = address(0x2000);
    uint256 public constant TOTAL_SUPPLY = 1_000_000_000 * 1e18; // 1B tokens, considering decimals
    
    function setUp() public {
        vm.startPrank(admin);
        token = new DeHealthToken();
        token.initialize(admin);
        vm.stopPrank();
    }

    function test_nonAdmin_cannot_loadBalances() public {
        uint256 amount = 1000 * 10 ** token.decimals();
        address[] memory addr = new address[](1);
        addr[0] = attacker;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;
        
        // Pre-attack state snapshot
        console.log("--- BEFORE-Trigger State ---");
        uint256 attackerBalanceBefore = token.balanceOf(attacker);
        uint256 totalSupplyBefore = token.totalSupply();
        console.log("Attacker balance (pre):", attackerBalanceBefore);
        console.log("Total supply (pre):", totalSupplyBefore);
        
        // Attempt to call as attacker
        console.log("--- Trigger Action: Attacker calls __loadBalances ---");
        (bool success, ) = address(token).call(
            abi.encodeWithSelector(token.__loadBalances.selector, addr, amounts)
        );
        console.log("Call result:", success ? "SUCCESS" : "REVERTED");
        
        // Post-attack state snapshot
        console.log("--- AFTER-Trigger State ---");
        uint256 attackerBalanceAfter = token.balanceOf(attacker);
        uint256 totalSupplyAfter = token.totalSupply();
        console.log("Attacker balance (post):", attackerBalanceAfter);
        console.log("Total supply (post):", totalSupplyAfter);
        
        // State change analysis
        bool stateChanged = (attackerBalanceAfter != attackerBalanceBefore) || 
                            (totalSupplyAfter != totalSupplyBefore);
        console.log("State changed:", stateChanged ? "YES" : "NO");
        
        // Vulnerability verdict - exactly one final line
        if (success || stateChanged) {
            console.log("Vulnerability Exists: Unauthorized state modification via __loadBalances");
        } else {
            console.log("Vulnerability not Exist: Access control enforced, state unchanged");
        }
    }

    function test_admin_can_loadBalances() public {
        // Verify initial state
        assertEq(token.balanceOf(admin), 0, "Admin should start with 0 balance");
        
        // Admin loads balances
        uint256 amount = 1000 * 10 ** token.decimals();
        address[] memory addr = new address[](1);
        addr[0] = admin;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;
        
        vm.prank(admin);
        token.__loadBalances(addr, amounts);
        
        // Verify balances updated correctly
        assertEq(token.balanceOf(admin), amount, "Admin should receive tokens");
        assertEq(token.totalSupply(), amount, "Total supply should reflect loaded balance");
    }
}