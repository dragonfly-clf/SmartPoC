// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "../src/CiccaDefi.sol";

contract MockPair {
    // Minimal implementation for pair contract
}

contract MockFactory {
    MockPair public pair;
    
    constructor(MockPair _pair) {
        pair = _pair;
    }
    
    function createPair(address, address) external view returns (address) {
        return address(pair);
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    address public constant testWETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    constructor(address _factory) {
        factory = _factory;
        WETH = testWETH;
    }
}

contract CiccaDefiTest is Test {
    CiccaDefi token;
    MockPair pair;
    MockFactory factory;
    MockRouter router;
    
    address constant REAL_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Deploy mock pair
        pair = new MockPair();
        
        // Deploy mock factory using mock pair
        factory = new MockFactory(pair);
        
        // Deploy mock router using mock factory
        router = new MockRouter(address(factory));
        
        // Mock the real router address
        vm.etch(REAL_ROUTER, address(router).code);
        
        // Deploy the token contract
        token = new CiccaDefi();
    }

    function testUncappedFeeSetting() public {
        address owner = token.owner();
        
        console.log("--- BEFORE-Trigger Fee Settings ---");
        // Get initial fee states
        uint256 preTax = token._taxFee();
        uint256 preLiq = token._liquidityFee();
        uint256 preStake = token._stakingFee();
        console.log("Tax Fee (pre): %s", preTax);
        console.log("Liquidity Fee (pre): %s", preLiq);
        console.log("Staking Fee (pre): %s", preStake);
        
        console.log("--- Trigger: Setting fees to 100% ---");
        vm.prank(owner);
        token.setTaxFeePercent(100);
        
        vm.prank(owner);
        token.setLiquidityFeePercent(100);
        
        vm.prank(owner);
        token.setStakingFeePercent(100);
        
        console.log("--- AFTER-Trigger Fee Settings ---");
        // Get post-fee modifier states
        uint256 postTax = token._taxFee();
        uint256 postLiq = token._liquidityFee();
        uint256 postStake = token._stakingFee();
        console.log("Tax Fee (post): %s", postTax);
        console.log("Liquidity Fee (post): %s", postLiq);
        console.log("Staking Fee (post): %s", postStake);
        
        // Final vulnerability verdict
        if(postTax == 100 && postLiq == 100 && postStake == 100) {
            console.log("Vulnerability Exists: Fees were successfully set to 100%");
        } else {
            console.log("Vulnerability not Exist: Contract prevented fee override");
        }
    }
}