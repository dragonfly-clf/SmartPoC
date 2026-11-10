// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LUCKYRABBITSPIN.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

contract MockRouter {
    address constant FACTORY_ADDRESS = address(0xC0FfEe);
    address constant WETH_ADDRESS = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    function factory() external pure returns (address) {
        return FACTORY_ADDRESS;
    }

    function WETH() external pure returns (address) {
        return WETH_ADDRESS;
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint, /* amountIn */
        uint, /* amountOutMin */
        address[] calldata, /* path */
        address, /* to */
        uint /* deadline */
    ) external {
        // Empty function - just to satisfy interface
    }
}

contract LUCKYRABBITSPINTest is Test {
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant FACTORY_ADDRESS = address(0xC0FfEe);

    LUCKYRABBITSPIN token;
    address owner = address(0x123);
    address development = address(0x456);
    address marketing = address(0x789);

    function setUp() public {
        // Deploy and etch mock factory
        MockFactory mockFactory = new MockFactory();
        vm.etch(FACTORY_ADDRESS, address(mockFactory).code);

        // Deploy and etch mock router
        MockRouter mockRouter = new MockRouter();
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);

        // Deploy token contract
        vm.startPrank(owner);
        token = new LUCKYRABBITSPIN();
        token.setNewDevAddress(payable(development));
        token.setNewMarketingAddress(payable(marketing));
        vm.stopPrank();
    }

    function testManualSwapWithInsufficientBalance() public {
        vm.startPrank(development);
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 contractTokenBalance = token.balanceOf(address(token));
        uint256 contractETHBalance = address(token).balance;
        console.log("Contract token balance: ", contractTokenBalance);
        console.log("Contract ETH balance: ", contractETHBalance);

        console.log("--- Trigger manualswap ---");
        bool manualswapReverted;
        try token.manualswap() {
            manualswapReverted = false;
        } catch {
            manualswapReverted = true;
        }
        console.log("manualswap reverted: ", manualswapReverted ? "YES" : "NO");

        console.log("--- MID-Trigger State ---");
        contractTokenBalance = token.balanceOf(address(token));
        contractETHBalance = address(token).balance;
        console.log("Contract token balance: ", contractTokenBalance);
        console.log("Contract ETH balance: ", contractETHBalance);

        console.log("--- Trigger manuals end ---");
        bool manualsendReverted;
        try token.manualsend() {
            manualsendReverted = false;
        } catch {
            manualsendReverted = true;
        }
        console.log("manualsend reverted: ", manualsendReverted ? "YES" : "NO");

        console.log("--- AFTER-Trigger State ---");
        contractTokenBalance = token.balanceOf(address(token));
        contractETHBalance = address(token).balance;
        console.log("Contract token balance: ", contractTokenBalance);
        console.log("Contract ETH balance: ", contractETHBalance);

        // Final verdict based on function behaviors
        if (!manualswapReverted || !manualsendReverted) {
            console.log("Vulnerability Exists: Functions allow execution with zero balance");
        } else {
            console.log("Vulnerability not Exist: Both functions revert as expected");
        }
        vm.stopPrank();
    }
}