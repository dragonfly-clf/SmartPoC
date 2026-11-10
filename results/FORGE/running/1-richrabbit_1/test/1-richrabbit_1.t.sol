// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/RichRabbitToken.sol";

contract MockRouter {
    function WETH() external pure returns (address) {
        return address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    }
}

contract RichRabbitTest is Test {
    RichRabbitToken token;
    address owner = makeAddr("owner");
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Deploy mock router at expected address
        MockRouter mockRouter = new MockRouter();
        bytes memory mockRouterCode = address(mockRouter).code;
        vm.etch(ROUTER_ADDRESS, mockRouterCode);

        // Deploy token normally
        vm.startPrank(owner);
        token = new RichRabbitToken();
        vm.stopPrank();
    }

    function test_FeeAboveLimitVulnerability() public {
        // Query initial fee states
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialDividendFeeRate = token.dividendFeeRate();
        uint256 initialFomoFeeRate = token.fomoFeeRate();
        uint256 initialSellRateUpper = token.sellRateUpper();
        uint256 initialSellRateBelow = token.sellRateBelow();
        uint256 initialFixSellSlippage = token.fixSellSlippage();
        console.log("Initial dividendFeeRate: %s", initialDividendFeeRate);
        console.log("Initial fomoFeeRate: %s", initialFomoFeeRate);
        console.log("Initial sellRateUpper: %s", initialSellRateUpper);
        console.log("Initial sellRateBelow: %s", initialSellRateBelow);
        console.log("Initial fixSellSlippage: %s", initialFixSellSlippage);

        // Trigger fee changes
        console.log("--- Trigger SetFeesAboveLimit ---");
        vm.startPrank(owner);
        token.setDividendFeeRate(30);
        token.setFomoFeeRate(30);
        token.setSellRateUpper(30);
        token.setSellRateBelow(30);
        token.updateFixSellSlippage(30);
        vm.stopPrank();

        // Query post-trigger fee states
        console.log("--- AFTER-Trigger State ---");
        uint256 currentDividendFeeRate = token.dividendFeeRate();
        uint256 currentFomoFeeRate = token.fomoFeeRate();
        uint256 currentSellRateUpper = token.sellRateUpper();
        uint256 currentSellRateBelow = token.sellRateBelow();
        uint256 currentFixSellSlippage = token.fixSellSlippage();
        console.log("Current dividendFeeRate: %s", currentDividendFeeRate);
        console.log("Current fomoFeeRate: %s", currentFomoFeeRate);
        console.log("Current sellRateUpper: %s", currentSellRateUpper);
        console.log("Current sellRateBelow: %s", currentSellRateBelow);
        console.log("Current fixSellSlippage: %s", currentFixSellSlippage);

        // Validate state changes
        console.log("--- State Comparison ---");
        bool vulnerabilityExists = false;
        vulnerabilityExists = vulnerabilityExists || (currentDividendFeeRate == 30);
        vulnerabilityExists = vulnerabilityExists || (currentFomoFeeRate == 30);
        vulnerabilityExists = vulnerabilityExists || (currentSellRateUpper == 30);
        vulnerabilityExists = vulnerabilityExists || (currentSellRateBelow == 30);
        vulnerabilityExists = vulnerabilityExists || (currentFixSellSlippage == 30);

        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Fees were set above 25%% limit");
        } else {
            console.log("Vulnerability not Exist: Fees remained within limit");
        }
    }
}