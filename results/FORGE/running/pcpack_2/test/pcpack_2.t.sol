// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PCPACK.sol";

contract PCPACKFeeManipulationTest is Test {
    PCPACK public token;
    address owner = address(this);
    address constant ROUTER_ADDRESS = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    function setUp() public {
        // Mock router and factory to avoid external calls
        address mockFactory = address(0x111);
        address mockWETH = address(0x222);
        address mockPair = address(0x333);

        // Mock router.factory()
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );

        // Mock router.WETH()
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );

        // Mock factory.createPair()
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );

        // Deploy token after mocks are set
        token = new PCPACK();
    }

    function testSellFeeCanExceed25Percent() public {
        console.log("--- BEFORE-Trigger Fee State ---");
        // Query initial fee state
        uint256 preFee = token.onSelltotalFees();
        console.log("Initial Fee:", preFee);
        console.log("Fee < 25%%: ", preFee < 25e18);
        
        console.log("--- Trigger Set Fee ---");
        // Owner sets fees to total 40% (10% each component)
        token.setSellFee(10e18, 10e18, 10e18, 10e18);
        
        console.log("--- AFTER-Trigger Fee State ---");
        // Query updated fee state
        uint256 postFee = token.onSelltotalFees();
        console.log("Updated Fee:", postFee);
        console.log("Fee > 25%%: ", postFee > 25e18);
        
        // Determine vulnerability existence
        bool vulnerabilityExists = postFee > 25e18;
        console.log("Validation Result:",
            vulnerabilityExists 
            ? "VULNERABLE - Fees exceeded 25% limit" 
            : "SAFE - Fees within limit"
        );
        
        // Final verdict output
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Owner can set sell fees above 25% without restrictions");
        } else {
            console.log("Vulnerability not Exist: Fee increase respects 25% limit");
        }
    }
}