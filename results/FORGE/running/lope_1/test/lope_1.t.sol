// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LOPE.sol";

contract LOPEFeeTest is Test {
    LOPE public token;
    address owner = address(0x1);
    address constant ROUTER_ADDRESS = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address constant MOCK_WETH = address(0x456);
    address constant MOCK_FACTORY = address(0x789);
    address constant MOCK_PAIR = address(0x123);

    function setUp() public {
        vm.startPrank(owner);
        
        // Mock router responses
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("factory()"),
            abi.encode(MOCK_FACTORY)
        );
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("WETH()"),
            abi.encode(MOCK_WETH)
        );
        
        // Mock factory response for any createPair call
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(MOCK_PAIR)
        );

        token = new LOPE();
        vm.stopPrank();
    }

    function testBuyFeeExceedsLimit() public {
        // Pre-trigger state: get and log initial fees
        console.log("--- BEFORE-Trigger Buy Fee ---");
        (uint256 projectFeeBefore, uint256 teamFeeBefore) = token.buyFee();
        uint256 totalBuyFeeBefore = projectFeeBefore + teamFeeBefore;
        console.log("Initial Buy Fee: Project=%d, Team=%d, Total=%d", 
            projectFeeBefore, teamFeeBefore, totalBuyFeeBefore);

        // Trigger: set fees to 30% (20+10)
        console.log("--- Trigger setBuyFee(20,10) ---");
        vm.prank(owner);
        token.setBuyFee(20, 10);

        // Post-trigger state: get and log updated fees
        console.log("--- AFTER-Trigger Buy Fee ---");
        (uint256 projectFeeAfter, uint256 teamFeeAfter) = token.buyFee();
        uint256 totalBuyFeeAfter = projectFeeAfter + teamFeeAfter;
        console.log("Updated Buy Fee: Project=%d, Team=%d, Total=%d", 
            projectFeeAfter, teamFeeAfter, totalBuyFeeAfter);
        
        // Vulnerability verification
        if (totalBuyFeeAfter > 25) {
            console.log("Vulnerability Exists: Buy fee exceeds 25%% limit (actual=%d%%)", totalBuyFeeAfter);
        } else {
            console.log("Vulnerability not Exist: Buy fee within 25%% limit (actual=%d%%)", totalBuyFeeAfter);
        }
    }

    function testSellFeeExceedsLimit() public {
        // Pre-trigger state: get and log initial fees
        console.log("--- BEFORE-Trigger Sell Fee ---");
        (uint256 projectFeeBefore, uint256 teamFeeBefore) = token.sellFee();
        uint256 totalSellFeeBefore = projectFeeBefore + teamFeeBefore;
        console.log("Initial Sell Fee: Project=%d, Team=%d, Total=%d", 
            projectFeeBefore, teamFeeBefore, totalSellFeeBefore);

        // Trigger: set fees to 35% (25+10)
        console.log("--- Trigger setSellFee(25,10) ---");
        vm.prank(owner);
        token.setSellFee(25, 10);

        // Post-trigger state: get and log updated fees
        console.log("--- AFTER-Trigger Sell Fee ---");
        (uint256 projectFeeAfter, uint256 teamFeeAfter) = token.sellFee();
        uint256 totalSellFeeAfter = projectFeeAfter + teamFeeAfter;
        console.log("Updated Sell Fee: Project=%d, Team=%d, Total=%d", 
            projectFeeAfter, teamFeeAfter, totalSellFeeAfter);
        
        // Vulnerability verification
        if (totalSellFeeAfter > 25) {
            console.log("Vulnerability Exists: Sell fee exceeds 25%% limit (actual=%d%%)", totalSellFeeAfter);
        } else {
            console.log("Vulnerability not Exist: Sell fee within 25%% limit (actual=%d%%)", totalSellFeeAfter);
        }
    }
}