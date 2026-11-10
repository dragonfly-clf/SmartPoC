// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CamKingToken.sol";

contract MockMaliciousReceiver {
    receive() external payable {
        revert("Malicious contract rejects ETH transfers");
    }
}

contract MockWETH {}

contract MockUniswapV2Factory {
    function createPair(address, address) external returns (address) {
        return address(0xCAFE);
    }
}

contract MockUniswapV2Router {
    address public immutable factory;
    address public immutable WETH;
    bool public swapCalled;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256, /* amountIn */
        uint256, /* amountOutMin */
        address[] calldata, /* path */
        address to,
        uint256 /* deadline */
    ) external {
        swapCalled = true;
        payable(to).transfer(0.5 ether);
    }
    
    function addLiquidityETH(
        address, /* token */
        uint256, /* amountTokenDesired */
        uint256, /* amountTokenMin */
        uint256, /* amountETHMin */
        address, /* to */
        uint256 /* deadline */
    ) external payable returns (uint256, uint256, uint256) {
        return (0, 0, 0);
    }
}

contract CamKingTokenTransfersTest is Test {
    CamKingToken token;
    MockMaliciousReceiver malicious;
    address owner;
    
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    uint256 tokenSupply = 1000000 ether;
    uint256 swapThreshold = 10 ether;
    address constant ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    function setUp() public {
        owner = address(this);
        
        // Deploy mock Uniswap contracts
        MockWETH weth = new MockWETH();
        MockUniswapV2Factory factory = new MockUniswapV2Factory();
        MockUniswapV2Router mockRouter = new MockUniswapV2Router(address(factory), address(weth));
        
        // Mock the router at fixed address
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        vm.deal(ROUTER_ADDRESS, 1 ether); // Fund the router
        
        vm.startPrank(owner);
        token = new CamKingToken();
        token.excludeFromFee(owner);
        token.excludeFromFee(address(token));
        
        // Configure swap settings
        token.setSwapAndLiquifyEnabled(true);
        token.setTaxFeePercent(100); // 10% fee
        token.setNumTokensSellToAddToLiquidity(swapThreshold);
        
        malicious = new MockMaliciousReceiver();
        vm.stopPrank();
        
        // Set token balances
        token.transfer(user1, tokenSupply);
        token.transfer(user2, tokenSupply);
    }

    function testEthTransferRevertsForMaliciousMarketingAddress() public {
        console.log("--- BEFORE-Trigger Action ---");
        console.log("Setting marketing address to malicious contract");
        
        token.setMarketingAddress(address(malicious));
        
        console.log("--- DURING-Trigger Preparation ---");
        console.log("Preparing swap by transfering tokens to contract");
        vm.startPrank(user1);
        token.transfer(address(token), swapThreshold * 2);
        vm.stopPrank();
        
        console.log("--- Trigger Transaction ---");
        console.log("Executing transfer to trigger swap/fee distribution");
        console.log("Expecting revert due to malicious contract behavior");
        
        vm.startPrank(user2);
        vm.expectRevert("Malicious contract rejects ETH transfers");
        token.transfer(address(0xDEAD), 1);
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger Result ---");
        console.log("Transfer transaction reverted as expected");
        console.log("Vulnerability Exists: Fee payout to malicious marketing address causes transaction reverts");
    }

    function testEthTransferRevertsForMaliciousDevAddress() public {
        console.log("--- BEFORE-Trigger Action ---");
        console.log("Setting dev address to malicious contract");
        
        token.setDevAddress(address(malicious));
        
        console.log("--- DURING-Trigger Preparation ---");
        console.log("Preparing swap by transfering tokens to contract");
        vm.startPrank(user1);
        token.transfer(address(token), swapThreshold * 2);
        vm.stopPrank();
        
        console.log("--- Trigger Transaction ---");
        console.log("Executing transfer to trigger swap/fee distribution");
        console.log("Expecting revert due to malicious contract behavior");
        
        vm.startPrank(user2);
        vm.expectRevert("Malicious contract rejects ETH transfers");
        token.transfer(address(0xDEAD), 1);
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger Result ---");
        console.log("Transfer transaction reverted as expected");
        console.log("Vulnerability Exists: Fee payout to malicious dev address causes transaction reverts");
    }
}