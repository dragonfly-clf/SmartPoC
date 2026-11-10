// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/APTD.sol";

contract ELFMExceedFeesTest is Test {
    APTD token;
    address owner = 0x22ba8aAb4c60Ac95e61CFC41dF8d2675aeb87C0b;
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address WBNB_ADDR = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // Fixed checksum

    function setUp() public {
        vm.startPrank(owner);
        
        // Mock router and factory calls during deployment
        address mockFactory = address(0xDECAF);
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        
        address mockPair = address(0xBEEF);
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );
        
        token = new APTD();
        token.tradingStatus(true);
        vm.stopPrank();
    }

    function test_FeeManipulationBeyondLimit() public {
        uint256 EXCESS_FEES = 26; // 26% is beyond 25% limit
        uint256 MAX_FEE_LIMIT = 25; // Maximum allowed fee percentage
        
        console.log("--- BEFORE-Trigger Actions ---");
        uint256 buyFeeBefore = token.buyTotalFees();
        uint256 sellFeeBefore = token.sellTotalFees();
        console.log("Buy fee before:", buyFeeBefore);
        console.log("Sell fee before:", sellFeeBefore);
        
        console.log("--- Trigger Actions ---");
        bool buySuccess = false;
        bool sellSuccess = false;
        
        vm.startPrank(owner);
        try token.updateBuyFees(EXCESS_FEES, 0) {
            buySuccess = true;
            console.log("Updated buy fee to:", EXCESS_FEES);
        } catch {
            console.log("updateBuyFees reverted");
        }
        try token.updateSellFees(0, EXCESS_FEES) {
            sellSuccess = true;
            console.log("Updated sell fee to:", EXCESS_FEES);
        } catch {
            console.log("updateSellFees reverted");
        }
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger Actions ---");
        uint256 buyFeeAfter = token.buyTotalFees();
        uint256 sellFeeAfter = token.sellTotalFees();
        console.log("Buy fee after:", buyFeeAfter);
        console.log("Sell fee after:", sellFeeAfter);

        // Validate vulnerability
        bool vulnerabilityExists = false;
        string memory reason = "Fee limits enforced as expected";
        
        if (buyFeeAfter > MAX_FEE_LIMIT) {
            vulnerabilityExists = true;
            reason = "Fee beyond 25% limit";
            console.log("Vulnerability: Buy fee exceeds maximum allowed limit");
        }
        if (sellFeeAfter > MAX_FEE_LIMIT) {
            vulnerabilityExists = true;
            reason = "Fee beyond 25% limit";
            console.log("Vulnerability: Sell fee exceeds maximum allowed limit");
        }

        // Final verdict
        console.log("-------- SUMMARY --------");
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists:", reason);
        } else {
            console.log("Vulnerability not Exist:", reason);
        }
    }
}