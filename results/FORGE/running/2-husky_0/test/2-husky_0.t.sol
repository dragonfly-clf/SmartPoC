// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/HuskyInu.sol";

contract HuskyStopTransactionsTest is Test {
    HuskyInu token;
    address owner = address(0x1);
    address user = address(0x123);
    address mockRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address mockWETH = address(0x111);
    address mockPair = address(0xabc);

    function setUp() public {
        vm.startPrank(owner);
        
        // Pre-calculate contract addresses
        address tokenAddr = computeCreateAddress(owner, vm.getNonce(owner));
        
        // Set up mock router responses
        vm.mockCall(
            mockRouter,
            abi.encodeWithSignature("factory()"),
            abi.encode(address(this)) // Use test contract as factory
        );
        vm.mockCall(
            mockRouter,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Set up mock factory (this contract)
        vm.mockCall(
            address(this),
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );
        
        // Create token with correct parameters
        token = new HuskyInu("Husky", "HUSY");
        
        // Distribute tokens
        token.transfer(user, token.totalSupply() / 2);
        vm.stopPrank();
    }
    
    // Mock factory function
    function createPair(address, address) external returns (address) {
        return mockPair;
    }

    function test_ownerCanStopUserTransactions() public {
        uint256 sellAmount = 1 ether;
        
        // User should be able to sell initially
        console.log("--- BEFORE-Trigger: User transfer to Uniswap ---");
        uint256 initialUserBalance = token.balanceOf(user);
        uint256 initialPairBalance = token.balanceOf(mockPair);
        console.log("Initial user balance:", initialUserBalance);
        console.log("Initial pair balance:", initialPairBalance);
        
        vm.prank(user);
        token.transfer(mockPair, sellAmount);
        
        uint256 afterFirstTransferUser = token.balanceOf(user);
        uint256 afterFirstTransferPair = token.balanceOf(mockPair);
        bool firstTransferSuccess = afterFirstTransferPair > initialPairBalance;
        console.log("After first transfer - user balance:", afterFirstTransferUser);
        console.log("After first transfer - pair balance:", afterFirstTransferPair);
        console.log("First transfer successful?", firstTransferSuccess);
        console.log("------------------------------------");
        
        // Owner enables restrictions
        console.log("--- Trigger: setLimitSell(true,0,0) ---");
        vm.prank(owner);
        token.setLimitSell(true, 0, 0); // Min=0, max=0 blocks all
        
        // Attempt user transaction after restriction (should be blocked)
        console.log("--- AFTER-Trigger: Attempt user transfer to Uniswap ---");
        uint256 beforeRestrictedTransferUser = token.balanceOf(user);
        uint256 beforeRestrictedTransferPair = token.balanceOf(mockPair);
        console.log("User balance pre-transfer:", beforeRestrictedTransferUser);
        console.log("Pair balance pre-transfer:", beforeRestrictedTransferPair);
        
        // Should revert due to restriction
        vm.startPrank(user);
        vm.expectRevert();
        token.transfer(mockPair, sellAmount);
        vm.stopPrank();
        
        // Capture state after restricted transfer attempt
        uint256 afterRestrictedTransferUser = token.balanceOf(user);
        uint256 afterRestrictedTransferPair = token.balanceOf(mockPair);
        console.log("User balance post-transfer-attempt:", afterRestrictedTransferUser);
        console.log("Pair balance post-transfer-attempt:", afterRestrictedTransferPair);
        
        // Differential comparison
        bool userBalUnchanged = (afterRestrictedTransferUser == beforeRestrictedTransferUser);
        bool pairBalUnchanged = (afterRestrictedTransferPair == beforeRestrictedTransferPair);
        bool restrictionEffective = (userBalUnchanged && pairBalUnchanged);
        console.log("User balance unchanged?", userBalUnchanged);
        console.log("Pair balance unchanged?", pairBalUnchanged);
        console.log("------------------------------------");
        
        // Final vulnerability verdict
        if (restrictionEffective) {
            console.log("Vulnerability Exist: Owner successfully blocked transactions while maintaining own transfer capabilities");
        } else {
            console.log("Vulnerability not Exist: User was still able to transfer after restrictions were enabled");
        }

        // Verify owner bypass (original functionality)
        vm.prank(owner);
        token.transfer(mockPair, sellAmount);
        assertEq(token.balanceOf(mockPair), afterRestrictedTransferPair + sellAmount);
    }
}