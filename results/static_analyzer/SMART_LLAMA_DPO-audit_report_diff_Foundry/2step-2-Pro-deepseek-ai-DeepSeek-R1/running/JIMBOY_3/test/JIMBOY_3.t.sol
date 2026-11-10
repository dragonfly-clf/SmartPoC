// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/JIMBOY.sol";

contract JIMBOYTest is Test {
    JIMBOY public token;
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant MOCK_FACTORY = address(0xFAa);
    address constant MOCK_WETH = address(0xDEAD);

    function setUp() public {
        token = new JIMBOY();
    }

    function test_setTradingWithInvalidPair() public {
        // Mock router's factory() call
        vm.mockCall(
            ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(MOCK_FACTORY)
        );
        
        // Mock router's WETH() call
        vm.mockCall(
            ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(MOCK_WETH)
        );
        
        // Mock failed pair creation (returns address(0))
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSignature("createPair(address,address)", address(token), MOCK_WETH),
            abi.encode(address(0))
        );

        console.log("--- BEFORE-Trigger State ---");
        address pairBefore = token.uniswapV2Pair();
        console.log("UniswapV2Pair address (pre):", pairBefore);

        console.log("--- Trigger setTrading(true) ---");
        vm.prank(token.owner());
        token.setTrading(true); // 关键攻击操作：在配对失败时启用交易

        console.log("--- AFTER-Trigger State ---");
        address pairAfter = token.uniswapV2Pair();
        console.log("UniswapV2Pair address (post):", pairAfter);

        // 漏洞判定：配对地址仍为0表明状态不一致漏洞存在
        bool vulnerabilityExists = (pairAfter == address(0));

        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Trading was enabled with invalid (0) pair address");
        } else {
            console.log("Vulnerability not Exist: Uniswap pair was properly set");
        }

        // 最终断言（保留原有逻辑）
        assertEq(pairAfter, address(0), "Pair address should be invalid after failed creation");
    }
}