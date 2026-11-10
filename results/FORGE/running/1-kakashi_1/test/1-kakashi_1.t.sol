// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KAKASHISENSEI.sol";

interface IUniswapV2Router {
    function factory() external pure returns (address);
}

contract FeeManipulationTest is Test {
    KAKASHISENSEI token;
    address owner = address(0x1);
    address constant ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    uint256 constant MAX_LIMIT = 25; // 25% threshold

    function setUp() public {
        // Deploy mock factory first
        MockFactory factory = new MockFactory();
        
        // Mock router's factory response
        vm.mockCall(
            ROUTER_ADDR,
            abi.encodeWithSelector(IUniswapV2Router.factory.selector),
            abi.encode(address(factory))
        );

        // Deploy token
        vm.startPrank(owner);
        token = new KAKASHISENSEI();
        vm.stopPrank();
    }

    function testFeeExceedLimit() public {
        uint256 excessiveFee = 30; // 30% exceeding limit
        
        console.log("--- BEFORE-Trigger SetFees ---");
        // Record initial fee rates
        uint256 initialBuyTaxFee = token._buyTaxFee();
        uint256 initialSellTaxFee = token._sellTaxFee();
        uint256 initialBuyBurnFee = token._buyBurnFee();
        uint256 initialSellBurnFee = token._sellBurnFee();
        uint256 initialBuyAdvertisementFee = token._buyAdvestisementFee();
        uint256 initialSellAdvertisementFee = token._sellAdvestisementFee();
        
        console.log("Initial Buy Tax Fee:", initialBuyTaxFee);
        console.log("Initial Sell Tax Fee:", initialSellTaxFee);
        console.log("Initial Buy Burn Fee:", initialBuyBurnFee);
        console.log("Initial Sell Burn Fee:", initialSellBurnFee);
        console.log("Initial Buy Advertisement Fee:", initialBuyAdvertisementFee);
        console.log("Initial Sell Advertisement Fee:", initialSellAdvertisementFee);
        
        console.log("--- Trigger SetFees ---");
        vm.startPrank(owner);
        // Set fees beyond 25% limit
        token.setTaxFeePercent(excessiveFee, excessiveFee);
        token.setBurnFee(excessiveFee, excessiveFee);
        token.setAdvestisementFeePercent(excessiveFee, excessiveFee);
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger SetFees ---");
        // Query updated fee rates
        uint256 updatedBuyTaxFee = token._buyTaxFee();
        uint256 updatedSellTaxFee = token._sellTaxFee();
        uint256 updatedBuyBurnFee = token._buyBurnFee();
        uint256 updatedSellBurnFee = token._sellBurnFee();
        uint256 updatedBuyAdvertisementFee = token._buyAdvestisementFee();
        uint256 updatedSellAdvertisementFee = token._sellAdvestisementFee();
        
        console.log("Updated Buy Tax Fee:", updatedBuyTaxFee);
        console.log("Updated Sell Tax Fee:", updatedSellTaxFee);
        console.log("Updated Buy Burn Fee:", updatedBuyBurnFee);
        console.log("Updated Sell Burn Fee:", updatedSellBurnFee);
        console.log("Updated Buy Advertisement Fee:", updatedBuyAdvertisementFee);
        console.log("Updated Sell Advertisement Fee:", updatedSellAdvertisementFee);
        
        // Check if any fee exceeded the maximum allowed limit
        bool feeExceeded = false;
        if (updatedBuyTaxFee > MAX_LIMIT) feeExceeded = true;
        if (updatedSellTaxFee > MAX_LIMIT) feeExceeded = true;
        if (updatedBuyBurnFee > MAX_LIMIT) feeExceeded = true;
        if (updatedSellBurnFee > MAX_LIMIT) feeExceeded = true;
        if (updatedBuyAdvertisementFee > MAX_LIMIT) feeExceeded = true;
        if (updatedSellAdvertisementFee > MAX_LIMIT) feeExceeded = true;
        
        if (feeExceeded) {
            console.log("Vulnerability Exists: At least one fee exceeded the maximum allowed limit of 25%%");
        } else {
            console.log("Vulnerability not Exist: All fees remain within the allowed limit of 25%%");
        }
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xdead);
    }
}