// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MarvinInu.sol";

contract MockWETH {
    function deposit() public payable {}
    function withdraw(uint) public {}
    function transfer(address, uint) public pure returns (bool) {
        return true;
    }
}

contract MockUniswapV2Pair {
    event Sync(uint112 reserve0, uint112 reserve1);
    function sync() public {
        emit Sync(0,0);
    }
}

contract MockUniswapV2Factory {
    address public immutable pair;
    
    constructor(address _pair) {
        pair = _pair;
    }
    
    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockUniswapV2Router {
    address public immutable factory;
    address public immutable weth;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        weth = _weth;
    }
    
    function WETH() external view returns (address) {
        return weth;
    }
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint, 
        uint, 
        address[] calldata, 
        address, 
        uint
    ) external {}
    
    function addLiquidityETH(
        address,
        uint,
        uint,
        uint,
        address,
        uint
    ) external payable returns (uint, uint, uint) {
        return (0,0,0);
    }
}

contract MarvinInuTest is Test {
    MarvinInu public token;
    address owner;
    address marketingWallet;
    address victim;
    address pairAddress;
    address constant ROUTER_ADDRESS = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    function setUp() public {
        owner = makeAddr("Owner");
        marketingWallet = makeAddr("MarketingWallet");
        victim = makeAddr("Victim");
        
        vm.deal(owner, 100 ether);
        // Setup mocks
        MockWETH mockWETH = new MockWETH();
        MockUniswapV2Pair mockPair = new MockUniswapV2Pair();
        MockUniswapV2Factory mockFactory = new MockUniswapV2Factory(address(mockPair));
        MockUniswapV2Router mockRouter = new MockUniswapV2Router(address(mockFactory), address(mockWETH));
        
        // Deploy mock router to hardcoded address
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        
        // Deploy token contract
        vm.startPrank(owner);
        token = new MarvinInu();
        token.enableTrading();
        token.updateMarketingWallet(marketingWallet);
        token.updateDevWallet(marketingWallet); // Set to same wallet
        token.removeLimits();
        
        // Send tokens to victim
        pairAddress = token.uniswapV2Pair();
        uint256 totalSupply = token.totalSupply();
        token.transfer(victim, totalSupply / 10);
        vm.stopPrank();
    }

    function testVulnerability() public {
        // Increase initial contract ETH to 1 ether
        deal(address(token), 1 ether);
        assertEq(address(token).balance, 1 ether, "Initial ETH balance should be 1 ether");

        // Pre-attack state checks
        emit log("--- BEFORE Trigger (transfer to dummy) ---");
        uint256 contractBalanceBefore = address(token).balance;
        uint256 marketingBalanceBefore = marketingWallet.balance;
        emit log_named_uint("Contract ETH Balance", contractBalanceBefore);
        emit log_named_uint("Marketing Wallet ETH Balance", marketingBalanceBefore);

        uint256 victimBalance = token.balanceOf(victim);
        vm.prank(victim);
        // Transfer to pair to accumulate fees
        token.transfer(pairAddress, victimBalance * 2 / 5);

        // Trigger vulnerability by transferring 1 token
        address dummy = makeAddr("dummy");
        emit log("--- Trigger Vulnerability (transfer to dummy) ---");
        vm.prank(victim);
        token.transfer(dummy, 1);

        // Post-attack state checks
        emit log("--- AFTER Trigger (transfer to dummy) ---");
        uint256 contractBalanceAfter = address(token).balance;
        uint256 marketingBalanceAfter = marketingWallet.balance;
        emit log_named_uint("Contract ETH Balance", contractBalanceAfter);
        emit log_named_uint("Marketing Wallet ETH Balance", marketingBalanceAfter);

        // Calculate balance changes
        uint256 contractBalanceChange = contractBalanceBefore - contractBalanceAfter;
        uint256 marketingBalanceChange = marketingBalanceAfter - marketingBalanceBefore;
        emit log_named_uint("Contract Balance Change", contractBalanceChange);
        emit log_named_uint("Marketing Balance Change", marketingBalanceChange);

        // Vulnerability exists if:
        // 1. Entire contract balance was drained (contract balance went from 1 ether to 0)
        // 2. All drained ETH was sent to marketing wallet
        bool vulnerabilityExists = (contractBalanceAfter == 0) && 
                                   (marketingBalanceChange == contractBalanceBefore);
        
        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Entire contract balance was sent to marketing wallet");
        } else {
            console.log("Vulnerability not Exist: ETH distribution mismatch");
        }
    }
}