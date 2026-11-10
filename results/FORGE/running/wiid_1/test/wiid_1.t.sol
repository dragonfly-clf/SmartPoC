// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/WEEDVERSESTRAINS.sol";

contract WEEDVERSESTRAINS_FeeTest is Test {
    WEEDVERSESTRAINS token;
    address owner = makeAddr("owner");
    uint256 constant MAX_RECOMMENDED_FEE = 25; // 25% maximum recommended fee
    
    function setUp() public {
        vm.startPrank(owner);

        // Setup mock addresses for router and factory
        address mockRouter = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address mockFactory = address(0x123);
        address mockWETH = address(0x456);
        address mockPair = address(0x789);

        // Mock router.facotry()
        vm.mockCall(
            mockRouter,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        
        // Mock router.WETH()
        vm.mockCall(
            mockRouter,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Mock factory.createPair()
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );

        token = new WEEDVERSESTRAINS();
        vm.stopPrank();
    }

    function test_fee_manipulation_exceeds_max() public {
        uint256 excessTaxFee = MAX_RECOMMENDED_FEE + 1;
        address attacker = makeAddr("attacker");
        bool vulnerabilityExists = true;

        // Non-owner cannot change fees
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setTaxFeePercent(excessTaxFee);

        // --- Tax Fee Manipulation Test ---
        console.log("\n--- START Tax Fee Test ---");
        uint256 initialTaxFee = token._taxFee();
        console.log("[PRE-STATE] Initial tax fee: %s", initialTaxFee);
        console.log("[ACTION] Owner setting tax fee to %s%%", excessTaxFee);
        
        vm.prank(owner);
        token.setTaxFeePercent(excessTaxFee);
        
        uint256 newTaxFee = token._taxFee();
        console.log("[POST-STATE] New tax fee: %s", newTaxFee);
        console.log(
            "[RESULT] %s: (%s -> %s)",
            newTaxFee == excessTaxFee ? "CHANGED" : "UNCHANGED",
            initialTaxFee,
            newTaxFee
        );
        
        if (newTaxFee != excessTaxFee) {
            vulnerabilityExists = false;
            console.log("Vulnerability condition failed for tax fee");
        }

        // --- Dev Fee Manipulation Test ---
        console.log("\n--- START Dev Fee Test ---");
        uint256 initialDevFee = token._devFee();
        console.log("[PRE-STATE] Initial dev fee: %s", initialDevFee);
        console.log("[ACTION] Owner setting dev fee to %s%%", excessTaxFee);
        
        vm.prank(owner);
        token.setDevFeePercent(excessTaxFee);
        
        uint256 newDevFee = token._devFee();
        console.log("[POST-STATE] New dev fee: %s", newDevFee);
        console.log(
            "[RESULT] %s: (%s -> %s)",
            newDevFee == excessTaxFee ? "CHANGED" : "UNCHANGED",
            initialDevFee,
            newDevFee
        );
        
        if (newDevFee != excessTaxFee) {
            vulnerabilityExists = false;
            console.log("Vulnerability condition failed for dev fee");
        }

        // --- Liquidity Fee Manipulation Test ---
        console.log("\n--- START Liquidity Fee Test ---");
        uint256 initialLiquidityFee = token._liquidityFee();
        console.log("[PRE-STATE] Initial liquidity fee: %s", initialLiquidityFee);
        console.log("[ACTION] Owner setting liquidity fee to %s%%", excessTaxFee);
        
        vm.prank(owner);
        token.setLiquidityFeePercent(excessTaxFee);
        
        uint256 newLiquidityFee = token._liquidityFee();
        console.log("[POST-STATE] New liquidity fee: %s", newLiquidityFee);
        console.log(
            "[RESULT] %s: (%s -> %s)",
            newLiquidityFee == excessTaxFee ? "CHANGED" : "UNCHANGED",
            initialLiquidityFee,
            newLiquidityFee
        );
        
        if (newLiquidityFee != excessTaxFee) {
            vulnerabilityExists = false;
            console.log("Vulnerability condition failed for liquidity fee");
        }

        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: All fees successfully set above maximum recommended value");
        } else {
            console.log("Vulnerability not Exist: Some fee setters failed to modify state or set to expected value");
        }
    }
    
    function test_fee_setters_have_no_upper_bound() public {
        uint256 extremeFeeValue = 99; // 99% fee
        bool vulnerabilityExists = true;

        vm.startPrank(owner);

        // --- Tax Fee Extreme Value Test ---
        console.log("\n--- START Extreme Tax Fee Test ---");
        uint256 initialTaxFee = token._taxFee();
        console.log("[PRE-STATE] Initial tax fee: %s", initialTaxFee);
        console.log("[ACTION] Owner setting tax fee to %s%%", extremeFeeValue);
        
        token.setTaxFeePercent(extremeFeeValue);
        
        uint256 newTaxFee = token._taxFee();
        console.log("[POST-STATE] New tax fee: %s", newTaxFee);
        console.log(
            "[RESULT] %s: (%s -> %s)",
            newTaxFee == extremeFeeValue ? "CHANGED" : "UNCHANGED",
            initialTaxFee,
            newTaxFee
        );
        
        if (newTaxFee != extremeFeeValue) {
            vulnerabilityExists = false;
            console.log("Vulnerability condition failed for tax fee");
        }

        // --- Dev Fee Extreme Value Test ---
        console.log("\n--- START Extreme Dev Fee Test ---");
        uint256 initialDevFee = token._devFee();
        console.log("[PRE-STATE] Initial dev fee: %s", initialDevFee);
        console.log("[ACTION] Owner setting dev fee to %s%%", extremeFeeValue);
        
        token.setDevFeePercent(extremeFeeValue);
        
        uint256 newDevFee = token._devFee();
        console.log("[POST-STATE] New dev fee: %s", newDevFee);
        console.log(
            "[RESULT] %s: (%s -> %s)",
            newDevFee == extremeFeeValue ? "CHANGED" : "UNCHANGED",
            initialDevFee,
            newDevFee
        );
        
        if (newDevFee != extremeFeeValue) {
            vulnerabilityExists = false;
            console.log("Vulnerability condition failed for dev fee");
        }

        // --- Liquidity Fee Extreme Value Test ---
        console.log("\n--- START Extreme Liquidity Fee Test ---");
        uint256 initialLiquidityFee = token._liquidityFee();
        console.log("[PRE-STATE] Initial liquidity fee: %s", initialLiquidityFee);
        console.log("[ACTION] Owner setting liquidity fee to %s%%", extremeFeeValue);
        
        token.setLiquidityFeePercent(extremeFeeValue);
        
        uint256 newLiquidityFee = token._liquidityFee();
        console.log("[POST-STATE] New liquidity fee: %s", newLiquidityFee);
        console.log(
            "[RESULT] %s: (%s -> %s)",
            newLiquidityFee == extremeFeeValue ? "CHANGED" : "UNCHANGED",
            initialLiquidityFee,
            newLiquidityFee
        );
        
        if (newLiquidityFee != extremeFeeValue) {
            vulnerabilityExists = false;
            console.log("Vulnerability condition failed for liquidity fee");
        }
        
        vm.stopPrank();

        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Fees successfully set to extreme values (99%%)");
        } else {
            console.log("Vulnerability not Exist: Some fees were not set to expected extreme value");
        }
    }
}