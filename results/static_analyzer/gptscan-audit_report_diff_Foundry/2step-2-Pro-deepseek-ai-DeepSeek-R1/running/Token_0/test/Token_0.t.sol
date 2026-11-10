// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Token.sol";

contract MockRouter {
    address public constant WETH = address(0x123);
    
    // State variables to capture slippage parameters
    uint public minToken;
    uint public minEth;
    
    receive() external payable {}
    
    function factory() external view returns (address) {
        return address(this); // Return self as factory
    }
    
    function createPair(address, address) external pure returns (address) {
        return address(0xbeef);
    }
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint, /* amountIn */
        uint, /* amountOutMin */
        address[] calldata, /* path */
        address to,
        uint /* deadline */
    ) external {
        payable(to).transfer(1 ether); // Send substantial ETH for liquidity
    }
    
    function addLiquidityETH(
        address, /* token */
        uint, /* amountTokenDesired */
        uint amountTokenMin,
        uint amountETHMin,
        address, /* to */
        uint /* deadline */
    ) external payable returns (uint, uint, uint) {
        // Record slippage parameters 
        minToken = amountTokenMin;
        minEth = amountETHMin;
        return (0, 0, 0); // Return dummy values matching signature
    }
}

contract NoSlippageCheckTest is Test {
    MockRouter public router;
    Token public token;
    
    function setUp() public {
        // Fund owner and create router
        address owner = makeAddr("owner");
        vm.deal(owner, 100 ether);
        
        vm.startPrank(owner);
        router = new MockRouter();
        deal(address(router), 1000 ether); // Fund router with sufficient ETH
        
        // Deploy token contract with mock router
        token = new Token(address(router));
        
        // Configure token settings
        token.setSwapAndLiquifyEnabled(true);
        uint256 decimals = token.decimals();
        uint256 liquidityTrigger = 10 * 10 ** decimals;
        token.setNumTokensSellToAddToLiquidity(liquidityTrigger);
        token.setMaxTxAmount(100 * 10 ** decimals);
        
        // Transfer tokens to token contract to meet liquidity threshold
        uint256 amount = 2 * liquidityTrigger;
        token.transfer(address(token), amount);
        vm.stopPrank();
    }
    
    function test_swapAndLiquifyHasNoSlippageControl() public {
        console.log("--- BEFORE-Trigger ---");
        console.log("No pre-state required: vulnerability checks parameter validation, not state change");
        
        console.log("--- Trigger Operation (transfer triggers swapAndLiquify) ---");
        address owner = token.owner();
        vm.prank(owner);
        token.transfer(makeAddr("recipient"), 1);
        
        console.log("--- AFTER-Trigger ---");
        uint tokenMin = router.minToken();
        uint ethMin = router.minEth();
        console.log("Recorded token min slippage:", tokenMin);
        console.log("Recorded ETH min slippage:", ethMin);
        
        // Skip state change verification as vulnerability is parameter-based
        console.log("--- Vulnerability Verdict ---");
        if (tokenMin == 0 && ethMin == 0) {
            console.log("Vulnerability Exists: swapAndLiquify calls contain zero slippage protection");
        } else {
            console.log("Vulnerability not Exist: Non-zero slippage parameters detected");
        }
    }
}