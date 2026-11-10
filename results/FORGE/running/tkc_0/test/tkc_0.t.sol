// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KingdomCoin.sol";

contract KingdomCoinFeeTest is Test {
    KingdomCoin token;
    address owner = makeAddr("owner");
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Mock router and factory calls
        address mockFactory = address(0x123);
        address mockWETH = address(0x456);
        address mockPair = address(0x789);
        
        // Mock router factory() call
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );

        // Mock router WETH() call
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );

        // Mock factory createPair call
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );

        vm.startPrank(owner);
        token = new KingdomCoin();
        vm.stopPrank();
    }

    function test_FeeManipulation() public {
        console.log("--- BEFORE-Trigger totalFees ---");
        uint256 beforeFees = token.totalFees();
        console.log("Total fees before trigger: ", beforeFees);

        console.log("--- Trigger updateFees ---");
        // Set fees to 26% (above project's 25% limit) - 0% operational + 26% buyBack
        vm.prank(owner);
        token.updateFees(26, 0);

        console.log("--- AFTER-Trigger totalFees ---");
        uint256 afterFees = token.totalFees();
        console.log("Total fees after trigger: ", afterFees);

        // Differential verification
        bool feeChanged = afterFees > 25;
        console.log("State changed (fees > 25%%):", feeChanged ? "Yes" : "No");
        console.log("Vulnerability verdict:", feeChanged ? "VULNERABLE" : "NOT VULNERABLE");
        
        // Final vulnerability verdict
        if (feeChanged) {
            console.log("Vulnerability Exists: Owner can set fees above the 25%% limit");
        } else {
            console.log("Vulnerability not Exist: Fees remain within 25%% limit");
        }
    }
}