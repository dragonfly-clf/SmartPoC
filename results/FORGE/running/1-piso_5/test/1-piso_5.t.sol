// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PISO.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xdd);
    }
}

contract MockRouter {
    MockFactory private _factory;
    
    constructor() {
        _factory = new MockFactory();
    }
    
    function factory() external view returns (address) {
        return address(_factory);
    }
    
    function WETH() external pure returns (address) {
        return address(0xee);
    }
    
    function addLiquidityETH(
        address, /* token */
        uint, /* amountTokenDesired */
        uint, /* amountTokenMin */
        uint, /* amountETHMin */
        address, /* to */
        uint /* deadline */
    ) external payable {}
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint, /* amountIn */
        uint, /* amountOutMin */
        address[] calldata, /* path */
        address, /* to */
        uint /* deadline */
    ) external {}
}

contract PISO_ZeroDivision_Test is Test {
    PISO token;
    MockRouter router;
    address owner;
    address user = makeAddr("user");

    function setUp() public {
        owner = address(this);
        router = new MockRouter();
        token = new PISO(address(router));
        
        // Setup taxes to zero as in original PoC
        token.setTaxes(0, 0, 0, 0, 0);
        token.setSellTaxes(0, 0, 0, 0, 0);
        
        // Enable trading and swapping
        token.setTradingStatus(true);
        token.updateSwapEnabled(true);
        token.updateSwapTokensAtAmount(1);
        
        // Fund token with balance for swapping
        token.transfer(address(token), 1);
        
        // Fund test user
        token.transfer(user, 100);
    }

    function test_revertsOnZeroDivision() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 userBalanceBefore = token.balanceOf(user);
        uint256 contractBalanceBefore = token.balanceOf(address(token));
        console.log("User balance before:", userBalanceBefore);
        console.log("Token contract balance before:", contractBalanceBefore);

        console.log("--- Trigger Transfer (expect revert) ---");
        vm.prank(user);
        vm.expectRevert();
        token.transfer(address(0xdead), 1); // Triggers swapAndLiquify

        console.log("--- AFTER-Trigger State ---");
        uint256 userBalanceAfter = token.balanceOf(user);
        uint256 contractBalanceAfter = token.balanceOf(address(token));
        console.log("User balance after:", userBalanceAfter);
        console.log("Token contract balance after:", contractBalanceAfter);

        // Verify balances remain unchanged after revert
        assertEq(userBalanceAfter, userBalanceBefore, "User balance changed after revert");
        assertEq(contractBalanceAfter, contractBalanceBefore, "Contract balance changed after revert");

        console.log("Vulnerability Exists: Division by zero occurs in swapAndLiquify");
    }
}