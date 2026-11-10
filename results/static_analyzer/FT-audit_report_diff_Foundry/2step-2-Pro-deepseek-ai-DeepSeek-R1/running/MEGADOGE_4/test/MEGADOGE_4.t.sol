// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console.sol"; // Added for logging
import "../src/MEGADOGE.sol";

contract MockWETH {
    function deposit() external payable {}
    function withdraw(uint) external {}
    function transfer(address, uint) external returns (bool) {}
    function balanceOf(address) external view returns (uint) {}
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
    address public factory;
    address public WETH;
    
    function initialize(address _factory, address _weth) external {
        factory = _factory;
        WETH = _weth;
    }
    
    function createPair(address tokenA, address tokenB) external returns (address) {
        return IUniswapV2Factory(factory).createPair(tokenA, tokenB);
    }
}

contract MEGADOGETest is Test {
    MEGADOGE token;
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant FAKE_PAIR = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address owner = address(0x1234);
    address marketingWallet = address(0x5678);
    address deadWallet = address(0xDEAD);
    
    function setUp() public {
        vm.startPrank(owner);
        
        // Deploy mock contracts
        MockWETH mockWETH = new MockWETH();
        MockUniswapV2Factory mockFactory = new MockUniswapV2Factory(FAKE_PAIR);
        
        // Set up router mock at fixed address
        MockUniswapV2Router mockRouter = new MockUniswapV2Router();
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        MockUniswapV2Router(ROUTER_ADDRESS).initialize(address(mockFactory), address(mockWETH));
        
        // Deploy token contract
        token = new MEGADOGE();
        vm.stopPrank();
    }

    function test_FeeManipulationVulnerability() public {
        vm.startPrank(owner);
        
        console.log("--- BEFORE-Trigger Fee ---");
        uint8 initialDogeFee = token.DOGERewardsFee();
        uint8 initialMarketingFee = token.marketingFee();
        uint8 initialTotalFee = initialDogeFee + initialMarketingFee;
        console.log("Initial DOGERewardsFee: ", initialDogeFee);
        console.log("Initial marketingFee:   ", initialMarketingFee);
        console.log("Initial Total Fee:      ", initialTotalFee);
        console.log("");
        
        console.log("--- Trigger ChangeFee ---");
        // Set fees beyond safe thresholds
        token.setDOGERewardsFee(22);
        token.setMarketingFee(22);
        console.log("Called setDOGERewardsFee(22)");
        console.log("Called setMarketingFee(22)");
        console.log("");
        
        console.log("--- AFTER-Trigger Fee ---");
        uint8 finalDogeFee = token.DOGERewardsFee();
        uint8 finalMarketingFee = token.marketingFee();
        uint8 finalTotalFee = finalDogeFee + finalMarketingFee;
        console.log("Final DOGERewardsFee:   ", finalDogeFee);
        console.log("Final marketingFee:     ", finalMarketingFee);
        console.log("Final Total Fee:        ", finalTotalFee);
        console.log("");
        
        // Comparison verdict
        bool feesChanged = (initialDogeFee != finalDogeFee) || 
                           (initialMarketingFee != finalMarketingFee);
        bool exceedsLimit = finalTotalFee > 25;
        
        console.log("--- Comparison Verdict ---");
        console.log("Fees changed?           %s", feesChanged ? "YES" : "NO");
        console.log("Combined fees > 25%%?    %s", exceedsLimit ? "YES" : "NO");
        
        // Final vulnerability assessment
        if (feesChanged && exceedsLimit) {
            console.log("Vulnerability Exists: Contract allows setting fees beyond safe limits (combined 44%% > 25%%)");
        } else {
            console.log("Vulnerability not Exist: Fees were not changed beyond safe thresholds");
        }
        
        vm.stopPrank();
    }
}