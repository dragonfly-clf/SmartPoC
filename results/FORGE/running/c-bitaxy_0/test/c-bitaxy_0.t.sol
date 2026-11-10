// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CryptoBitaxy.sol";

contract CryptoBitaxyTest is Test {
    CryptoBitaxy token;
    
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant MOCK_FACTORY = address(0xABC);
    address constant MOCK_WETH = address(0xDEF);
    address constant MOCK_PAIR = address(0x123);

    function setUp() public {
        // Mock router - factory
        vm.mockCall(
            ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(MOCK_FACTORY)
        );
        
        // Mock router - WETH
        vm.mockCall(
            ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(MOCK_WETH)
        );
        
        // Mock factory - createPair
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(MOCK_PAIR)
        );

        token = new CryptoBitaxy();
    }

    function test_fee_exceeds_limit() public {
        // BEFORE: Capture initial fee values
        console.log("--- BEFORE-Trigger Fee Values ---");
        uint256 taxFeeBefore = token._taxFee();
        uint256 burnFeeBefore = token._burnFee();
        uint256 charityFeeBefore = token._charityFee();
        uint256 liquidityFeeBefore = token._liquidityFee();
        console.log("Initial _taxFee:", taxFeeBefore);
        console.log("Initial _burnFee:", burnFeeBefore);
        console.log("Initial _charityFee:", charityFeeBefore);
        console.log("Initial _liquidityFee:", liquidityFeeBefore);

        // TRIGGER: Attack operations
        console.log("--- Trigger: Set All Fees to 30% ---");
        token.setTaxFeePercent(30);
        token.setBurnFeePercent(30);
        token.setChartityFeePercent(30);
        token.setLiquidityFeePercent(30);
        
        // AFTER: Capture final fee values
        console.log("--- AFTER-Trigger Fee Values ---");
        uint256 taxFeeAfter = token._taxFee();
        uint256 burnFeeAfter = token._burnFee();
        uint256 charityFeeAfter = token._charityFee();
        uint256 liquidityFeeAfter = token._liquidityFee();
        console.log("Final _taxFee:", taxFeeAfter);
        console.log("Final _burnFee:", burnFeeAfter);
        console.log("Final _charityFee:", charityFeeAfter);
        console.log("Final _liquidityFee:", liquidityFeeAfter);
        
        // VERDICT: Determination logic
        console.log("--- Vulnerability Check ---");
        bool feesModified = 
            (taxFeeAfter == 30) &&
            (burnFeeAfter == 30) &&
            (charityFeeAfter == 30) &&
            (liquidityFeeAfter == 30);
        
        if (feesModified) {
            console.log("Vulnerability Exists: All fees successfully set to 30%, exceeding 25% limit");
        } else {
            console.log("Vulnerability not Exist: Fees not fully modified to exploit value");
        }
    }
}