// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DogeSuperman.sol";

contract MockWETH9 {
    function deposit() external payable {}
    function transfer(address, uint256) external pure returns (bool) { return true; }
}

contract MockUniswapV2Pair {
    function sync() external {}
}

contract MockUniswapV2Factory {
    address immutable public pair;
    
    constructor(address _pair) {
        pair = _pair;
    }
    
    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockUniswapV2Router02 {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint, /* amountIn */
        uint, /* amountOutMin */
        address[] calldata, /* path */
        address, /* to */
        uint /* deadline */
    ) external {
        // Mock implementation does nothing
    }
}

contract DogeSupermanTest is Test {
    DogeSuperman token;
    
    address constant owner = 0xE536307a914BCE3dc231F8ca30e5e19D72F460fb;
    address devWallet = makeAddr("dev_wallet");
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    uint256 constant INITIAL_BALANCE = 1000 ether;
    MockUniswapV2Pair mockPair;
    MockUniswapV2Router02 mockRouter;

    function setUp() public {
        // Create and etch WETH
        MockWETH9 mockWETH = new MockWETH9();
        vm.etch(address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c), address(mockWETH).code);
        
        // Create mock pair and factory
        mockPair = new MockUniswapV2Pair();
        MockUniswapV2Factory mockFactory = new MockUniswapV2Factory(address(mockPair));
        
        // Deploy and etch router
        mockRouter = new MockUniswapV2Router02(address(mockFactory), address(mockWETH));
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        
        // Deploy token contract
        token = new DogeSuperman();
        
        // Post-deployment configuration
        vm.startPrank(owner);
        
        // Set dev wallet using contract function
        token.Wallet_Update_Dev(payable(devWallet));
        
        // Exclude contract from fees to prevent burn during transfers
        token.excludeFromFee(address(token));
        
        // Transfer tokens to contract to simulate accumulated fees
        token.transfer(address(token), INITIAL_BALANCE);
        
        vm.stopPrank();
    }

    function testStateInconsistencyIssue() public {
        /********************** BEFORE TRIGGER **********************/
        uint256 preTriggerBalance = token.balanceOf(address(token));
        console.log("--- BEFORE-Trigger Contract Balance---");
        console.log("Contract token balance (pre-trigger):", preTriggerBalance);
        assertEq(preTriggerBalance, INITIAL_BALANCE, "Initial contract balance mismatch");

        /********************** TRIGGER ACTIONS **********************/
        console.log("--- Trigger Action: process_Tokens_Now(100) ---");
        vm.prank(owner);
        token.process_Tokens_Now(100); // Process 100% of tokens

        /********************** AFTER TRIGGER **********************/
        console.log("--- AFTER-Trigger Contract Balance---");
        uint256 postTriggerBalance = token.balanceOf(address(token));
        console.log("Contract token balance (post-trigger):", postTriggerBalance);

        /********************** VALIDATION & VERDICT **********************/
        console.log("--- Balance Change Validation ---");
        bool inconsistencyDetected = (preTriggerBalance == postTriggerBalance);
        if (inconsistencyDetected) {
            console.log("Balance remained unchanged (expected reduction)");
            console.log("Vulnerability Exists: Contract token balance not reduced, indicating state inconsistency issue");
        } else {
            console.log("Balance changed as expected");
            console.log("Vulnerability not Exist: Contract token balance was reduced, indicating successful processing of tokens");
        }
    }
}