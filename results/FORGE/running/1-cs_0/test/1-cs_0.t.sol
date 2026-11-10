// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CryptoStellar.sol";

contract FixedMockWETH {
    function deposit() public payable {}
    function transfer(address, uint) public pure returns (bool) {return true;}
}

contract FixedMockPair {
    uint112 public reserve0 = 1e18;
    uint112 public reserve1 = 1e18;
    function sync() external {}
}

contract FixedMockFactory {
    address immutable pairAddress;
    constructor(address _pair) {
        pairAddress = _pair;
    }
    function createPair(address, address) external view returns (address) {
        return pairAddress;
    }
}

contract FixedMockRouter {
    address immutable routerFactory;
    address immutable routerWETH;
    
    constructor(address _factory, address _weth) {
        routerFactory = _factory;
        routerWETH = _weth;
    }
    
    function WETH() external view returns (address) {
        return routerWETH;
    }
    
    function factory() external view returns (address) {
        return routerFactory;
    }
}

contract CryptoStellarTest is Test {
    CryptoStellar token;
    FixedMockWETH weth;
    FixedMockPair pair;
    address owner;
    address user = address(0x123);
    address dead = 0x000000000000000000000000000000000000dEaD;
    uint initialSupply;
    address tokenPair;

    function setUp() public {
        owner = address(this);
        
        // Deploy mock ETH and pair
        weth = new FixedMockWETH();
        pair = new FixedMockPair();
        FixedMockFactory factory = new FixedMockFactory(address(pair));
        FixedMockRouter router = new FixedMockRouter(address(factory), address(weth));
        
        // Override PancakeSwap router address
        address routerAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        vm.etch(routerAddr, address(router).code);
        
        // Deploy token
        token = new CryptoStellar();
        
        // Configure test environment
        tokenPair = token.uniswapPair();
        vm.prank(owner);
        token.setMarketPairStatus(tokenPair, true);

        // Exempt from limits for test setup
        vm.prank(owner);
        token.setIsTxLimitExempt(owner, true);
        vm.prank(owner);
        token.setIsTxLimitExempt(user, true);
        vm.prank(owner);
        token.setIsTxLimitExempt(tokenPair, true);

        initialSupply = token.totalSupply();
        vm.prank(owner);
        token.transfer(user, initialSupply / 4);

        // Fund token pair
        vm.prank(owner);
        token.transfer(tokenPair, initialSupply / 4);
    }

    // Test: Owner sets sell tax above 100% should revert
    function testSellTaxOverflow() public {
        // Set sell taxes to total 101%
        vm.prank(owner);
        token.setSellTaxes(90, 10, 1); // 90 + 10 + 1 = 101%
        
        // User approves transfer
        uint sellAmount = 1000 * 10**token.decimals();
        vm.prank(user);
        token.approve(address(this), sellAmount);

        // Attempt transfer to market pair - should revert with subtraction overflow
        vm.expectRevert("SafeMath: subtraction overflow");
        token.transferFrom(user, tokenPair, sellAmount);
    }

    // Test: High coolBlock causes token burning
    function testCoolBlockBurning() public {
        console.log("--- BEFORE-Trigger State ---");
        uint deadBalanceBefore = token.balanceOf(dead);
        console.log("Dead Address Balance Before:", deadBalanceBefore);

        console.log("--- Trigger CoolBlock Mechanism ---");
        // Set extremely long cool period
        vm.prank(owner);
        token.setCoolBlock(1000000);
        
        // Simulate buy (transfer from market pair to user)
        vm.prank(tokenPair);
        token.transfer(user, 1);

        // Trigger burn by transferring from user
        vm.prank(user);
        token.transfer(address(0x456), 1);

        console.log("--- AFTER-Trigger State ---");
        uint deadBalanceAfter = token.balanceOf(dead);
        console.log("Dead Address Balance After:", deadBalanceAfter);

        uint burnedTokens = deadBalanceAfter - deadBalanceBefore;
        console.log("Calculated Burned Tokens:", burnedTokens);
        
        // Vulnerability verdict logic
        if (deadBalanceAfter > deadBalanceBefore) {
            console.log("Vulnerability Exists: Setting high coolBlock caused unexpected token burning");
        } else {
            console.log("Vulnerability not Exist: No token burning occurred after setting coolBlock");
        }

        // Final assertion check
        assertEq(deadBalanceAfter, deadBalanceBefore + 1, "Burned tokens not detected");
    }
}