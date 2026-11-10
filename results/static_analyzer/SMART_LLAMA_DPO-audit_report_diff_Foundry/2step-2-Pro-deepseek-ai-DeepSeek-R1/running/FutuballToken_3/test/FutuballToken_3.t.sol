// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FutuballToken.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

contract MockRouter {
    address public factory;
    address public immutable WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
}

contract FutuballTokenTest is Test {
    FutuballToken token;
    address owner = address(0x1);
    address user1 = address(0x2);
    address user2 = address(0x3);
    
    // Hardcoded PancakeSwap addresses
    address constant pancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant pancakeFactory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    
    MockFactory mockFactory;
    MockRouter mockRouter;

    function setUp() public {
        // Create mock router with bytecode
        mockRouter = new MockRouter();
        vm.etch(pancakeRouter, address(mockRouter).code);
        
        // Deploy mock factory
        mockFactory = new MockFactory();
        
        // Set factory address in router's storage
        vm.store(
            pancakeRouter,
            bytes32(uint256(0)), 
            bytes32(uint256(uint160(address(mockFactory))))
        );
        
        // Deploy token contract
        vm.prank(owner);
        token = new FutuballToken();
        
        // Transfer initial tokens to test user
        vm.prank(owner);
        token.transfer(user1, 100 ether);
    }

    function testInconsistentStateOnTransfer() public {
        uint256 initialTotalSupply = token.totalSupply();
        uint256 user1Balance = token.balanceOf(user1);
        uint256 user2BalanceBefore = token.balanceOf(user2);
        
        console.log("--- BEFORE-Trigger Transfer ---");
        console.log("user1 balance:", user1Balance);
        console.log("user2 balance:", user2BalanceBefore);
        console.log("total supply:", initialTotalSupply);
        
        // Attempt to transfer more than balance
        uint256 invalidTransferAmount = user1Balance + 1 ether;
        
        console.log("--- Trigger Transfer ---");
        // Expect revert with ERC20 error
        vm.prank(user1);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        token.transfer(user2, invalidTransferAmount);

        // Query state after transfer
        uint256 user1BalanceAfter = token.balanceOf(user1);
        uint256 user2BalanceAfter = token.balanceOf(user2);
        uint256 totalSupplyAfter = token.totalSupply();
        
        console.log("--- AFTER-Trigger Transfer ---");
        console.log("user1 balance:", user1BalanceAfter);
        console.log("user2 balance:", user2BalanceAfter);
        console.log("total supply:", totalSupplyAfter);
        
        // Compare state change
        bool user1Changed = (user1BalanceAfter != user1Balance);
        bool user2Changed = (user2BalanceAfter != user2BalanceBefore);
        bool supplyChanged = (totalSupplyAfter != initialTotalSupply);
        bool anyChange = user1Changed || user2Changed || supplyChanged;
        
        // Vulnerability verdict
        if (anyChange) {
            console.log("Vulnerability Exists: State changed after invalid transfer");
        } else {
            console.log("Vulnerability not Exist: State remains consistent after invalid transfer");
        }

        // Verify no state changes occurred
        assertEq(token.balanceOf(user1), user1Balance, "Sender balance should remain unchanged");
        assertEq(token.balanceOf(user2), 0, "Recipient balance should remain 0");
        assertEq(token.totalSupply(), initialTotalSupply, "Total supply should remain unchanged");
    }
}