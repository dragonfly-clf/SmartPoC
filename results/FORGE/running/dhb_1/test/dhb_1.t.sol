// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DemonHellboy.sol";

contract DemonHellboyFeeTest is Test {
    DemonHellboy token;
    address owner = address(0x123);
    address hardcodedRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address mockFactory;
    address mockPair;
    address mockWETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function setUp() public {
        vm.startPrank(owner);
        createMocks();
        
        // Mock router factory() call
        vm.mockCall(
            hardcodedRouter,
            abi.encodeWithSelector(bytes4(keccak256("factory()"))),
            abi.encode(mockFactory)
        );
        
        // Mock router WETH() call
        vm.mockCall(
            hardcodedRouter,
            abi.encodeWithSelector(bytes4(keccak256("WETH()"))),
            abi.encode(mockWETH)
        );
        
        // Mock factory createPair() call
        vm.mockCall(
            mockFactory,
            abi.encodeWithSelector(bytes4(keccak256("createPair(address,address)"))),
            abi.encode(mockPair)
        );
        
        token = new DemonHellboy();
        vm.stopPrank();
    }
    
    function createMocks() private {
        // Create minimal mock contracts
        mockFactory = address(new MockContract());
        mockPair = address(new MockContract());
    }
    
    function test_SetLiquidityFeeBeyondLimit() public {
        console.log("--- BEFORE-Trigger LiquidityFee ---");
        uint256 beforeFee = token._liquidityFee();
        console.log("Initial liquidity fee:", beforeFee);
        
        console.log("--- Trigger setLiquidityFeePercent(26) ---");
        vm.prank(owner);
        token.setLiquidityFeePercent(26);
        
        console.log("--- AFTER-Trigger LiquidityFee ---");
        uint256 afterFee = token._liquidityFee();
        console.log("Post-attack liquidity fee:", afterFee);
        
        // Vulnerability verification
        if (afterFee == 26) {
            console.log("Vulnerability Exists: liquidityFee was set to 26% beyond the limit");
        } else {
            console.log("Vulnerability not Exist: Liquidity fee change unsuccessful");
        }
    }
    
    function test_SetMarketingDivisorBeyondLimit() public {
        console.log("--- BEFORE-Trigger MarketingDivisor ---");
        uint256 beforeDivisor = token.marketingDivisor();
        console.log("Initial marketing divisor:", beforeDivisor);
        
        console.log("--- Trigger setMarketingDivisor(26) ---");
        vm.prank(owner);
        token.setMarketingDivisor(26);
        
        console.log("--- AFTER-Trigger MarketingDivisor ---");
        uint256 afterDivisor = token.marketingDivisor();
        console.log("Post-attack marketing divisor:", afterDivisor);
        
        // Vulnerability verification
        if (afterDivisor == 26) {
            console.log("Vulnerability Exists: marketingDivisor was set to 26% beyond the limit");
        } else {
            console.log("Vulnerability not Exist: Marketing divisor change unsuccessful");
        }
    }
}

contract MockContract {
    fallback() external payable {
        // Minimal mock contract
    }
}