// test/ExceedLimitFeeTest.t.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0x456);
    }
}

contract MockUniswapV2Router {
    address public factory;
    
    constructor() {
        factory = address(new MockUniswapV2Factory());
    }
    
    function WETH() external pure returns (address) {
        return address(0x789);
    }
}

contract ExceedLimitFeeTest is Test {
    CoinToken token;
    address owner;
    MockUniswapV2Router mockRouter;
    address feeAddress = address(0x2);
    address constant MOCK_ROUTER_ADDRESS = address(0x3);

    function setUp() public {
        owner = address(this);
        mockRouter = new MockUniswapV2Router();
        
        token = new CoinToken(
            "TestToken", 
            "TEST", 
            0,          // Use 0 decimal places
            1000000,    // Total supply - 1M tokens
            1,          // Initial tax fee (1%)
            1,          // Initial liquidity fee (1%)
            1,          // Initial dev fee (1%)
            address(mockRouter),
            feeAddress,
            owner
        );
    }

    // Test fee parameters can be set above 25% without restrictions
    function testFeeCanExceed25Percent() public {
        console.log("--- BEFORE-Trigger Attempt ---");
        console.log("Attempting to set fees to 26%...");

        console.log("--- Trigger SetFees ---");
        (bool taxSuccess, ) = address(token).call(abi.encodeWithSignature("setTaxFeePercent(uint256)", 26));
        (bool liqSuccess, ) = address(token).call(abi.encodeWithSignature("setLiquidityFeePercent(uint256)", 26));
        (bool devSuccess, ) = address(token).call(abi.encodeWithSignature("setDevFeePercent(uint256)", 26));
        
        console.log("--- AFTER-Trigger Results ---");
        console.log("setTaxFeePercent (26%):", taxSuccess ? "SUCCESS" : "FAILED");
        console.log("setLiquidityFeePercent (26%):", liqSuccess ? "SUCCESS" : "FAILED");
        console.log("setDevFeePercent (26%):", devSuccess ? "SUCCESS" : "FAILED");

        if (taxSuccess && liqSuccess && devSuccess) {
            console.log("Vulnerability Exists: All fees were set above 25% without revert");
        } else {
            console.log("Vulnerability not Exist: Setting fees above 25% reverted");
        }
    }
}