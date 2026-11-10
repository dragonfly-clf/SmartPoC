// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/AIOToken.sol";

contract AIOTokenBurnTest is Test {
    AIOToken token;
    
    // Test accounts
    address owner = vm.addr(0x1);
    address tokenBurner = vm.addr(0x2);
    address regularUser = vm.addr(0x3);
    
    // Constants
    address constant PANCAKE_FACTORY = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address constant WBNB_TOKEN = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function setUp() public {
        // Mock Pancake Factory to avoid external calls
        MockFactory mockFactory = new MockFactory();
        vm.etch(PANCAKE_FACTORY, address(mockFactory).code);

        // Deploy token with needed setup
        vm.startPrank(owner);
        token = new AIOToken();
        token.setTokenBurner(tokenBurner);
        
        // Calculate safe transfer amount (10% of owner balance)
        uint256 ownerBalance = token.balanceOf(owner);
        require(ownerBalance > 0, "Owner has no balance");
        uint256 transferAmount = ownerBalance / 10;
        
        token.transfer(regularUser, transferAmount);
        vm.stopPrank();
    }

    function test_tokenBurnerCanBurnAnyUserTokens() public {
        // Pre-burn state
        console2.log("--- BEFORE-Trigger Burn ---");
        uint256 initialUserBalance = token.balanceOf(regularUser);
        uint256 initialTotalSupply = token.totalSupply();
        console2.log("Regular user balance before:", initialUserBalance);
        console2.log("Total supply before:", initialTotalSupply);

        console2.log("--- Trigger Burn ---");
        // Token burner burns all user's tokens
        vm.startPrank(tokenBurner);
        token.burn(regularUser, initialUserBalance);
        vm.stopPrank();

        console2.log("--- AFTER-Trigger Burn ---");
        uint256 afterUserBalance = token.balanceOf(regularUser);
        uint256 afterTotalSupply = token.totalSupply();
        console2.log("Regular user balance after:", afterUserBalance);
        console2.log("Total supply after:", afterTotalSupply);

        // Vulnerability verification
        bool userBalanceWiped = (afterUserBalance == 0);
        bool supplyDecreased = (afterTotalSupply == initialTotalSupply - initialUserBalance);
        bool vulnerable = userBalanceWiped && supplyDecreased;

        // Verify token removal
        assertEq(afterUserBalance, 0, "User should have 0 tokens");
        assertEq(
            afterTotalSupply,
            initialTotalSupply - initialUserBalance,
            "Total supply not decreased correctly"
        );

        // Final vulnerability verdict
        if (vulnerable) {
            console2.log("Vulnerability Exists: Token burner can arbitrarily burn any user's tokens");
        } else {
            console2.log("Vulnerability not Exist: Token burn operation failed as expected");
        }
    }
    
    function test_nonBurnerCannotBurnTokens() public {
        // Get user balance to burn
        uint256 burnAmount = token.balanceOf(regularUser);
        
        // Attempt to burn as non-burner (should revert)
        vm.prank(regularUser);
        vm.expectRevert("Access denied: only for 'token burners'");
        token.burn(regularUser, burnAmount);
    }
}

// Minimal Pancake Factory mock
contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1);
    }
}