// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GUARDDOGE.sol";

contract MockDexRouter {
    constructor() {}

    function factory() external pure returns (address) {
        return address(0x1234);
    }
    
    function WETH() external pure returns (address) {
        return address(0xCAFE);
    }
    
    function addLiquidityETH(
        address,
        uint,
        uint,
        uint,
        address,
        uint
    ) external payable returns (uint, uint, uint) {}
}

contract MockDexFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1111);
    }
}

contract GuardDogeFeeManipulationTest is Test {
    GUARDDOGE token;
    address constant owner = address(0xBEEF);
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant FACTORY_ADDRESS = address(0x1234);

    function setUp() public {
        // Deploy mock contracts
        vm.etch(ROUTER_ADDRESS, type(MockDexRouter).runtimeCode);
        vm.etch(FACTORY_ADDRESS, type(MockDexFactory).runtimeCode);
        
        // Deploy token contract
        vm.prank(owner);
        token = new GUARDDOGE();
        
        // Authorize test contract to call functions
        vm.prank(owner);
        token.authorize(address(this));
    }

    // Helper to read storage slots
    function readUint256(uint256 slot) private view returns (uint256 value) {
        bytes32 s = vm.load(address(token), bytes32(slot));
        value = uint256(s);
    }

    struct FeeState {
        uint256 liquidityFee;
        uint256 buybackFee;
        uint256 reflectionFee;
        uint256 marketingFee;
        uint256 feeDenominator;
        uint256 totalFee;
        uint256 threshold;
    }

    function getFeeState(uint256 denominatorSlot) private view returns (FeeState memory) {
        FeeState memory state;
        state.liquidityFee = readUint256(5);
        state.buybackFee = readUint256(6);
        state.reflectionFee = readUint256(7);
        state.marketingFee = readUint256(8);
        state.feeDenominator = readUint256(denominatorSlot);
        state.totalFee = state.liquidityFee + state.buybackFee + state.reflectionFee + state.marketingFee;
        state.threshold = (state.feeDenominator * 25) / 100;
        return state;
    }

    function test_CanSetFeesBeyondLimitWithoutRevert() public {
        // Test parameters for excessive fees
        uint256 newLiquidityFee = 26;
        uint256 newBuybackFee = 26;
        uint256 newReflectionFee = 26;
        uint256 newMarketingFee = 26;
        uint256 newFeeDenominator = 100;

        console.log("--- BEFORE-Trigger Fee State ---");
        FeeState memory beforeState = getFeeState(10);
        console.log("Liquidity Fee Before:", beforeState.liquidityFee);
        console.log("Buyback Fee Before:", beforeState.buybackFee);
        console.log("Reflection Fee Before:", beforeState.reflectionFee);
        console.log("Marketing Fee Before:", beforeState.marketingFee);
        console.log("Fee Denominator Before:", beforeState.feeDenominator);
        console.log("Total Fee Before:", beforeState.totalFee);
        console.log("Threshold (25% of denominator):", beforeState.threshold);
        console.log("Fee exceeds threshold? %s", beforeState.totalFee > beforeState.threshold ? "YES" : "NO");

        console.log("--- Trigger SetFees ---");
        vm.prank(owner);
        token.setFees(
            newLiquidityFee,
            newBuybackFee,
            newReflectionFee,
            newMarketingFee,
            newFeeDenominator
        );

        console.log("--- AFTER-Trigger Fee State ---");
        FeeState memory afterState = getFeeState(10);
        console.log("Liquidity Fee After:", afterState.liquidityFee);
        console.log("Buyback Fee After:", afterState.buybackFee);
        console.log("Reflection Fee After:", afterState.reflectionFee);
        console.log("Marketing Fee After:", afterState.marketingFee);
        console.log("Fee Denominator After:", afterState.feeDenominator);
        console.log("Total Fee After:", afterState.totalFee);
        console.log("Threshold (25% of denominator):", afterState.threshold);
        console.log("Fee exceeds threshold? %s", afterState.totalFee > afterState.threshold ? "YES" : "NO");
        
        // Vulnerability verdict logic
        if (afterState.totalFee > afterState.threshold) {
            console.log("Vulnerability Exists: Fees successfully set beyond 25% threshold");
        } else {
            console.log("Vulnerability not Exist: Fees remain within safe threshold after manipulation");
        }
    }
}