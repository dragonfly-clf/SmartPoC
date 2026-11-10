// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CiccaDefi.sol";

// Mock contracts to simulate Uniswap environment
contract MockWETH {
    function balanceOf(address) external pure returns (uint256) {
        return 1 ether;
    }
}

contract MockUniswapV2Pair {
    function sync() external {}
}

contract MockUniswapV2Factory {
    mapping(address => mapping(address => address)) public getPair;
    address public pairImplementation;
    
    constructor(address _pairImplementation) {
        pairImplementation = _pairImplementation;
    }
    
    function createPair(address tokenA, address tokenB) external returns (address) {
        address pair = address(new MockUniswapV2Pair());
        getPair[tokenA][tokenB] = pair;
        getPair[tokenB][tokenA] = pair;
        return pair;
    }
}

contract MockUniswapV2Router {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _WETH) {
        factory = _factory;
        WETH = _WETH;
    }
}

contract CiccaDefiTest is Test {
    CiccaDefi public token;
    address owner = address(0x1);
    address nonOwner = address(0x2);
    
    function setUp() public {
        // Deploy mock contracts
        MockWETH weth = new MockWETH();
        MockUniswapV2Pair pairImpl = new MockUniswapV2Pair();
        MockUniswapV2Factory factory = new MockUniswapV2Factory(address(pairImpl));
        MockUniswapV2Router mockRouter = new MockUniswapV2Router(address(factory), address(weth));
        
        // Override real router address with mock
        vm.etch(0x10ED43C718714eb63d5aA57B78B54704E256024E, address(mockRouter).code);
        
        // Deploy token contract
        vm.startPrank(owner);
        token = new CiccaDefi();
        vm.stopPrank();
    }
    
    function test_setFeesBeyondLimit() public {
        console.log("--- BEFORE-Trigger Fee State ---");
        // Capture initial fee states
        uint256 initialTaxFee = token._taxFee();
        uint256 initialLiquidityFee = token._liquidityFee();
        uint256 initialStakingFee = token._stakingFee();
        console.log("Initial taxFee:", initialTaxFee);
        console.log("Initial liquidityFee:", initialLiquidityFee);
        console.log("Initial stakingFee:", initialStakingFee);
        
        console.log("--- Trigger SettingFees ---");
        // Set fees beyond 25% limit (26-100%)
        vm.startPrank(owner);
        token.setTaxFeePercent(26);
        token.setLiquidityFeePercent(26);
        token.setStakingFeePercent(26);
        
        token.setTaxFeePercent(100);
        token.setLiquidityFeePercent(100);
        token.setStakingFeePercent(100);
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger Fee State ---");
        // Capture final fee states
        uint256 finalTaxFee = token._taxFee();
        uint256 finalLiquidityFee = token._liquidityFee();
        uint256 finalStakingFee = token._stakingFee();
        console.log("Final taxFee:", finalTaxFee);
        console.log("Final liquidityFee:", finalLiquidityFee);
        console.log("Final stakingFee:", finalStakingFee);
        
        // Vulnerability verification: Check if any fee exceeds 25%
        bool vulnerabilityExists = finalTaxFee > 25 || 
                                   finalLiquidityFee > 25 || 
                                   finalStakingFee > 25;
        
        console.log("-----------------------------");
        console.log("Fee State Diff Verification:");
        console.log("Initial Tax Fee:", initialTaxFee, "| After Tax Fee:", finalTaxFee);
        console.log("Initial Liquidity Fee:", initialLiquidityFee, "| After Liquidity Fee:", finalLiquidityFee);
        console.log("Initial Staking Fee:", initialStakingFee, "| After Staking Fee:", finalStakingFee);
        
        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Verdict: State changed ABOVE 25% limit - Vulnerability Exploited");
            console.log("Vulnerability Exists: Owner can set fees beyond 25% limit");
        } else {
            console.log("Verdict: State did NOT exceed 25% limit - Vulnerability not Exploited");
            console.log("Vulnerability not Exist: Fee limit enforcement works as expected");
        }
    }
    
    function test_nonOwnerCannotSetFees() public {
        vm.startPrank(nonOwner);
        
        // Non-owner should be unable to set fees
        vm.expectRevert("Ownable: caller is not the owner");
        token.setTaxFeePercent(10);
        
        vm.expectRevert("Ownable: caller is not the owner");
        token.setLiquidityFeePercent(10);
        
        vm.expectRevert("Ownable: caller is not the owner");
        token.setStakingFeePercent(10);
        
        vm.stopPrank();
    }
}