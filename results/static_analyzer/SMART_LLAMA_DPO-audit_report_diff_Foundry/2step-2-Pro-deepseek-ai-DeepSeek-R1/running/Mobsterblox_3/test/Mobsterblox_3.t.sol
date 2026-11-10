// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Mobsterblox.sol";

contract MockWETH {
    function deposit() public payable {}
    function transfer(address to, uint value) public pure returns (bool) {
        return true;
    }
    function withdraw(uint) public pure {}
}

contract MockUniswapV2Pair {
    function sync() external {}
    function token0() external view returns (address) {return address(0);}
    function token1() external view returns (address) {return address(0);}
}

contract MockUniswapV2Factory {
    address public pair;

    constructor() {
        pair = address(new MockUniswapV2Pair());
    }

    function getPair(address, address) external view returns (address) {
        return pair;
    }

    function createPair(address, address) external returns (address) {
        return pair;
    }
}

contract MockUniswapV2Router {
    address public factory;
    address public WETH;
    
    constructor(address _factory, address _WETH) {
        factory = _factory;
        WETH = _WETH;
    }

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint, uint, uint) {
        return (0, 0, 0);
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external {}
}

contract MobsterbloxTest is Test {
    Mobsterblox token;
    MockUniswapV2Factory factory;
    MockUniswapV2Router router;
    MockWETH weth;

    address owner = address(this);
    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        // Deploy mock contracts
        weth = new MockWETH();
        factory = new MockUniswapV2Factory();
        router = new MockUniswapV2Router(address(factory), address(weth));

        // Deploy token contract with mocks
        token = new Mobsterblox(
            "TestToken",               // name
            "TST",                     // symbol
            18,                        // decimals
            100000000,                 // total supply (100 million)
            1,                         // tax fee
            1,                         // LP fee
            1,                         // dev fee
            address(router),           // router address (mock)
            address(0xdead),           // dev wallet
            owner,                     // token owner
            address(0)                 // service address
        );
        
        // Configure token settings
        token.setSwapAndLiquifyEnabled(true);
        token.setNumTokensSellToAddToLiquidity(100_000 * 10**18); // 100k tokens
    }

    function test_swapAndLiquifyInconsistentStateUpdate() public {
        uint256 tokenAmount = 100 * 10**18; // 100 tokens with 18 decimals

        // Transfer tokens to contract to trigger swapAndLiquify
        uint256 contractAmount = token.numTokensSellToAddToLiquidity() * 2;
        token.transfer(address(token), contractAmount);
        
        // ---- First transfer ----
        console.log("--- BEFORE-Trigger (First Transfer) ---");
        bool statusBeforeFirst = token.swapAndLiquifyEnabled();
        console.log("swapAndLiquifyEnabled state: %s", statusBeforeFirst);
        
        console.log("--- Trigger First Transfer ---");
        token.transfer(user1, tokenAmount);
        
        console.log("--- AFTER-Trigger (First Transfer) ---");
        bool statusAfterFirst = token.swapAndLiquifyEnabled();
        console.log("swapAndLiquifyEnabled state: %s", statusAfterFirst);
        console.log("State unchanged: %s", statusBeforeFirst == statusAfterFirst);
        
        // ---- Second transfer ----
        console.log("--- BEFORE-Trigger (Second Transfer) ---");
        bool statusBeforeSecond = token.swapAndLiquifyEnabled();
        console.log("swapAndLiquifyEnabled state: %s", statusBeforeSecond);
        
        console.log("--- Trigger Second Transfer ---");
        token.transfer(user2, tokenAmount);
        
        console.log("--- AFTER-Trigger (Second Transfer) ---");
        bool statusAfterSecond = token.swapAndLiquifyEnabled();
        console.log("swapAndLiquifyEnabled state: %s", statusAfterSecond);
        console.log("State unchanged: %s", statusBeforeSecond == statusAfterSecond);
        
        // Final vulnerability verdict
        if (statusAfterFirst && statusAfterSecond) {
            console.log("Vulnerability Exists: swapAndLiquifyEnabled remains enabled during multiple transfers");
        } else {
            console.log("Vulnerability not Exist: swapAndLiquifyEnabled disabled during transfers");
        }
        
        // Original assertions preserved
        assertTrue(statusBeforeFirst, "Initial state should be enabled");
        assertTrue(statusAfterFirst, "Should remain enabled after first transfer");
        assertTrue(statusAfterSecond, "Should remain enabled after second transfer");
    }
}