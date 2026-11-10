// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234);
    }
}

contract MockUniswapV2Router {
    address public factory;
    address public immutable WETH;
    
    constructor(address _factory) {
        factory = _factory;
        WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
}

contract FeeManipulationTest is Test {
    CoinToken token;
    address owner = makeAddr("owner");
    address feeAddress = makeAddr("feeAddress");
    address service = makeAddr("service");
    uint256 constant SERVICE_FEE = 0.1 ether;
    
    function setUp() public {
        // Deploy mock Uniswap contracts
        MockUniswapV2Factory factory = new MockUniswapV2Factory();
        MockUniswapV2Router router = new MockUniswapV2Router(address(factory));
        
        // Initialize token parameters
        string memory name = "Test Token";
        string memory symbol = "TEST";
        uint256 decimals = 18;
        uint256 supply = 1000000 * 10 ** decimals;
        uint256 txFee = 1;
        uint256 lpFee = 1;
        uint256 devFee = 1;

        // Deploy token with proper router address
        vm.deal(owner, SERVICE_FEE);
        vm.prank(owner);
        token = new CoinToken{value: SERVICE_FEE}(
            name, symbol, decimals, supply, txFee,
            lpFee, devFee, address(router),
            feeAddress, owner, service
        );
    }

    function testFeeManipulation() public {
        // Record initial fee percentages
        console.log("--- BEFORE-Trigger State ---");
        uint256 taxFeeBefore = token._taxFee();
        uint256 devFeeBefore = token._devFee();
        uint256 liquidityFeeBefore = token._liquidityFee();
        console.log("taxFeeBefore:", taxFeeBefore);
        console.log("devFeeBefore:", devFeeBefore);
        console.log("liquidityFeeBefore:", liquidityFeeBefore);

        console.log("--- Trigger ChangeFee ---");
        vm.startPrank(owner);
        // Set all fees beyond the 25% limit
        token.setTaxFeePercent(26);
        token.setDevFeePercent(26);
        token.setLiquidityFeePercent(26);
        vm.stopPrank();

        // Record fee percentages after manipulation
        console.log("--- AFTER-Trigger State ---");
        uint256 taxFeeAfter = token._taxFee();
        uint256 devFeeAfter = token._devFee();
        uint256 liquidityFeeAfter = token._liquidityFee();
        console.log("taxFeeAfter:", taxFeeAfter);
        console.log("devFeeAfter:", devFeeAfter);
        console.log("liquidityFeeAfter:", liquidityFeeAfter);

        // Check if any fee parameter exceeds 25%
        bool taxExceeded = taxFeeAfter > 25;
        bool devExceeded = devFeeAfter > 25;
        bool liquidityExceeded = liquidityFeeAfter > 25;
        bool vulnerabilityExists = taxExceeded || devExceeded || liquidityExceeded;

        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Fees successfully set above 25%% limit");
        } else {
            console.log("Vulnerability not Exist: All fees remain at/below 25%% limit");
        }
        
        // Assert final outcome
        assertEq(
            vulnerabilityExists, 
            true, 
            "Fees should exceed 25% limit but didn't"
        );
    }
}