// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FeelrToken.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xD000000000000000000000000000000000000000);
    }
}

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    }

    function WETH() external pure returns (address) {
        return address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }

    function addLiquidityETH(
        address,
        uint256,
        uint256,
        uint256,
        address,
        uint256
    ) external payable returns (uint256, uint256, uint256) {
        return (0, 0, 0);
    }
}

contract FixPrivilegeEscalationTest is Test {
    FeelrToken token;
    address owner = address(0x1);
    uint256 constant PERCENT_DIVIDER = 1000;

    function setUp() public {
        // Mock Uniswap contracts
        address ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        address FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
        
        vm.etch(FACTORY, address(new MockFactory()).code);
        vm.etch(ROUTER, address(new MockRouter()).code);

        vm.prank(owner);
        token = new FeelrToken();
    }

    function test_ownerPrivilegeEscalation() public {
        uint256 totalSupply = token.totalSupply();
        
        vm.startPrank(owner);
        
        // Test setBuyFeePercent
        console2.log("--- BEFORE-setBuyFeePercent ---");
        uint256 initialBuyFee = token.marketingFeeOnBuying();
        console2.log("Initial buy fee:", initialBuyFee);
        
        uint256 maxFee = PERCENT_DIVIDER * 15 / 100;
        token.setBuyFeePercent(maxFee);
        
        console2.log("--- AFTER-setBuyFeePercent ---");
        uint256 newBuyFee = token.marketingFeeOnBuying();
        console2.log("New buy fee:", newBuyFee);
        assertEq(newBuyFee, maxFee, "Buy fee not set correctly");
        
        // Test setSellFeePercent
        console2.log("--- BEFORE-setSellFeePercent ---");
        uint256 initialSellFee = token.marketingFeeOnSelling();
        console2.log("Initial sell fee:", initialSellFee);
        
        token.setSellFeePercent(maxFee);
        
        console2.log("--- AFTER-setSellFeePercent ---");
        uint256 newSellFee = token.marketingFeeOnSelling();
        console2.log("New sell fee:", newSellFee);
        assertEq(newSellFee, maxFee, "Sell fee not set correctly");
        
        // Test setMinTokenToSwap
        console2.log("--- BEFORE-setMinTokenToSwap ---");
        uint256 initialMinSwap = token.minTokenToSwap();
        console2.log("Initial minTokenToSwap:", initialMinSwap);
        
        token.setMinTokenToSwap(1);
        
        console2.log("--- AFTER-setMinTokenToSwap ---");
        uint256 newMinSwap = token.minTokenToSwap();
        console2.log("New minTokenToSwap:", newMinSwap);
        assertEq(newMinSwap, 1, "MinTokenToSwap not set correctly");
        
        // Test setMaxHoldLimit
        console2.log("--- BEFORE-setMaxHoldLimit ---");
        uint256 initialMaxHold = token.maxHoldLimit();
        console2.log("Initial maxHoldLimit:", initialMaxHold);
        
        uint256 maxHoldLimit = totalSupply / PERCENT_DIVIDER;
        token.setMaxHoldLimit(maxHoldLimit);
        
        console2.log("--- AFTER-setMaxHoldLimit ---");
        uint256 newMaxHold = token.maxHoldLimit();
        console2.log("New maxHoldLimit:", newMaxHold);
        assertEq(newMaxHold, maxHoldLimit, "MaxHoldLimit not set correctly");
        
        // Test setDistributionStatus
        console2.log("--- BEFORE-setDistributionStatus ---");
        bool initialSwapStatus = token.autoSwapStatus();
        console2.log("Initial autoSwapStatus:", initialSwapStatus);
        
        token.setDistributionStatus(false);
        
        console2.log("--- AFTER-setDistributionStatus ---");
        bool newSwapStatus = token.autoSwapStatus();
        console2.log("New autoSwapStatus:", newSwapStatus);
        assertTrue(!newSwapStatus, "AutoSwapStatus not disabled");
        
        // Test enableTrading
        console2.log("--- BEFORE-enableTrading ---");
        bool initialTradingStatus = token.trading();
        console2.log("Initial trading status:", initialTradingStatus);
        
        token.enableTrading();
        
        console2.log("--- AFTER-enableTrading ---");
        bool newTradingStatus = token.trading();
        console2.log("New trading status:", newTradingStatus);
        assertTrue(newTradingStatus, "Trading not enabled");
        
        vm.stopPrank();
        console2.log("Vulnerability Exists: Owner successfully set critical parameters to extreme values");
    }

    function test_onlyOwnerCanSetCriticalParameters() public {
        address attacker = address(0x666);
        uint256 totalSupply = token.totalSupply();
        
        // Remember initial states
        uint256 initialBuyFee = token.marketingFeeOnBuying();
        uint256 initialSellFee = token.marketingFeeOnSelling();
        uint256 initialMinSwap = token.minTokenToSwap();
        uint256 initialMaxHold = token.maxHoldLimit();
        bool initialSwapStatus = token.autoSwapStatus();
        bool initialTradingStatus = token.trading();
        
        // Non-owner attempts to change settings
        vm.startPrank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setBuyFeePercent(PERCENT_DIVIDER * 15 / 100);
        assertEq(token.marketingFeeOnBuying(), initialBuyFee, "Unauthorized change to buy fee");
        
        vm.expectRevert("Ownable: caller is not the owner");
        token.setSellFeePercent(PERCENT_DIVIDER * 15 / 100);
        assertEq(token.marketingFeeOnSelling(), initialSellFee, "Unauthorized change to sell fee");
        
        vm.expectRevert("Ownable: caller is not the owner");
        token.setMinTokenToSwap(1);
        assertEq(token.minTokenToSwap(), initialMinSwap, "Unauthorized change to minTokenToSwap");
        
        vm.expectRevert("Ownable: caller is not the owner");
        token.setMaxHoldLimit(totalSupply / PERCENT_DIVIDER);
        assertEq(token.maxHoldLimit(), initialMaxHold, "Unauthorized change to maxHoldLimit");
        
        vm.expectRevert("Ownable: caller is not the owner");
        token.setDistributionStatus(false);
        assertEq(token.autoSwapStatus(), initialSwapStatus, "Unauthorized change to autoSwapStatus");
        
        vm.expectRevert("Ownable: caller is not the owner");
        token.enableTrading();
        assertEq(token.trading(), initialTradingStatus, "Unauthorized change to trading status");
        vm.stopPrank();
        
        console2.log("Vulnerability not Exist: Only owner can set critical parameters");
    }
}