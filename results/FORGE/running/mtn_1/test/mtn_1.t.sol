// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

contract MockUniswapV2Router {
    address public immutable factory;
    
    constructor() {
        factory = address(new MockUniswapV2Factory());
    }
    
    function WETH() external pure returns (address) {
        return address(0xE);
    }
}

contract CoinTokenTaxFeeTest is Test {
    CoinToken token;
    MockUniswapV2Router mockRouter;
    
    address owner = address(0x1);
    address marketingAddr = address(0x2);
    address lpPoolAddr = address(0x3);
    
    function setUp() public {
        mockRouter = new MockUniswapV2Router();
        
        vm.deal(owner, 1 ether);
        vm.startPrank(owner);
        
        token = new CoinToken{value: 1 ether}(
            "TestToken", 
            "TKN", 
            1000000 * 10**9,   // _ts
            1,                  // initial taxFee (1%)
            1,                  // buybackFee (1%)
            1,                  // marketingFee (1%)
            marketingAddr,
            address(mockRouter),
            lpPoolAddr
        );
        
        vm.stopPrank();
    }

    function test_OwnerCanSetTaxFeeExceeding25Percent() public {
        console.log("--- BEFORE-Trigger Tax Fee State ---");
        uint256 preTaxFee = token._taxFee();
        console.log("Initial tax fee:", preTaxFee, "%");

        console.log("--- Trigger setTaxFee(26%) ---");
        uint256 illegalTaxFee = 26; // 26% which exceeds 25% limit
        
        // Attempt to set illegal tax fee
        vm.prank(owner);
        token.setTaxFee(illegalTaxFee);

        console.log("--- AFTER-Trigger Tax Fee State ---");
        uint256 postTaxFee = token._taxFee();
        console.log("Updated tax fee:", postTaxFee, "%");

        // Differential verification
        bool taxFeeChanged = (postTaxFee == illegalTaxFee);
        bool vulnerabilityExists = taxFeeChanged;
        
        console.log("Difference check:", taxFeeChanged ? "Tax fee changed" : "Tax fee NOT changed");
        if (vulnerabilityExists) {
            console.log("Verdict: Vulnerability exploited - tax fee exceeded 25% limit");
            console.log("Vulnerability Exists: Owner set tax fee to 26%, violating 25% maximum limit");
        } else {
            console.log("Verdict: Vulnerability NOT exploited - limit enforcement works");
            console.log("Vulnerability not Exist: Tax fee was not changed to illegal value of 26%");
        }
    }
}