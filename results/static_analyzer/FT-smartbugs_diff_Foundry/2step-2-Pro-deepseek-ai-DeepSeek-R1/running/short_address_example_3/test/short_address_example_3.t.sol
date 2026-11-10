// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/short_address_example.sol";

contract MyTokenReturnValueTest is Test {
    MyToken token;
    address deployer = vm.addr(1);
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    
    function setUp() public {
        // Deploy token with specific deployer as tx.origin
        vm.startPrank(deployer, deployer);
        token = new MyToken();
        vm.stopPrank();
    }

    function testUncheckedReturnValueFailsSilently() public {
        console.log("--- BEFORE-Trigger state ---");
        uint256 deployerBalanceBefore = token.getBalance(deployer);
        uint256 user1BalanceBefore = token.getBalance(user1);
        uint256 user2BalanceBefore = token.getBalance(user2);
        
        console.log("Deployer balance:", deployerBalanceBefore);
        console.log("User1 balance:", user1BalanceBefore);
        console.log("User2 balance:", user2BalanceBefore);
        
        console.log("--- Trigger: unchecked sendCoin call ---");
        vm.prank(user1);
        token.sendCoin(user2, 1000); // Danger: ignoring return value!
        
        console.log("--- AFTER-Trigger state ---");
        uint256 deployerBalanceAfter = token.getBalance(deployer);
        uint256 user1BalanceAfter = token.getBalance(user1);
        uint256 user2BalanceAfter = token.getBalance(user2);
        
        console.log("Deployer balance:", deployerBalanceAfter);
        console.log("User1 balance:", user1BalanceAfter);
        console.log("User2 balance:", user2BalanceAfter);
        
        // Compare balances before and after
        bool stateRemainedUnchanged = 
            (deployerBalanceBefore == deployerBalanceAfter) &&
            (user1BalanceBefore == user1BalanceAfter) &&
            (user2BalanceBefore == user2BalanceAfter);
        
        // Final vulnerability verdict
        if (stateRemainedUnchanged) {
            console.log("Vulnerability Exists: The transfer failed without reverting and state remained unchanged, demonstrating silent failure vulnerability.");
        } else {
            console.log("Vulnerability not Exist: The transfer unexpectedly changed balances, which shouldn't occur with 0 sender balance.");
        }
        
        // Original assertions preserved
        assertEq(token.getBalance(user1), 0, "user1 balance remains 0");
        assertEq(token.getBalance(user2), 0, "user2 balance remains 0");
        assertEq(token.getBalance(deployer), 10000, "deployer balance unchanged");
    }
    
    function testCheckedReturnValueCatchesFailure() public {
        // Verify initial state
        assertEq(token.getBalance(deployer), 10000, "deployer initial balance");
        assertEq(token.getBalance(user1), 0, "user1 initial balance");
        assertEq(token.getBalance(user2), 0, "user2 initial balance");

        // Properly check return value
        vm.prank(user1);
        bool success = token.sendCoin(user2, 1000);
        assertFalse(success, "Transfer should fail due to insufficient balance");
    }
}