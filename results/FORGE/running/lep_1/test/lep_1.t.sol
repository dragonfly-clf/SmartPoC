// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LEP.sol";

contract LEPFeeTest is Test {
    LEP public token;
    address payable owner;

    // Valid checksum mock addresses
    address constant MOCK_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant MOCK_FACTORY = 0xf000000000000000000000000000000000000000;
    address constant MOCK_WETH = 0xE000000000000000000000000000000000000000;
    address constant MOCK_PAIR = 0xD000000000000000000000000000000000000000;

    function setUp() public {
        // Mock router factory()
        vm.mockCall(
            MOCK_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(MOCK_FACTORY)
        );
        
        // Mock router WETH()
        vm.mockCall(
            MOCK_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(MOCK_WETH)
        );
        
        // Mock factory createPair()
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(MOCK_PAIR)
        );

        // Deploy token
        token = new LEP();
        owner = payable(address(this));
    }

    function testFeeLimitExceeded() public {
        // Start prank as owner
        vm.startPrank(owner);
        
        // Set initial fees to zero to avoid overflow issues
        token.setLiquiditFee(0);
        token.setBackFee(0);
        token.setMarketingFee(0);
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 feesBefore = token.totalFees();
        console.log("Initial total fees (%):", feesBefore);
        
        console.log("--- Trigger: setMarketingFee(26) ---");
        // Set marketing fee to 26% (exceeds 25% limit)
        token.setMarketingFee(26);
        
        console.log("--- AFTER-Trigger State ---");
        uint256 feesAfter = token.totalFees();
        console.log("Final total fees (%):", feesAfter);
        
        console.log("--- Comparison Verdict ---");
        console.log("Fees increased:", feesAfter > feesBefore ? "YES" : "NO");
        console.log("Fees exceed 25% threshold:", feesAfter > 25 ? "YES" : "NO");
        
        // Final vulnerability verdict
        if (feesAfter > 25) {
            console.log("Vulnerability Exists: Marketing fee was successfully set beyond 25% limit");
        } else {
            console.log("Vulnerability not Exist: Total fees remain within 25% limit");
        }
        
        vm.stopPrank();
    }
    
    // Helper to receive ether
    receive() external payable {}
}