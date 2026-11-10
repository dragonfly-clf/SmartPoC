// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GMTdoge.sol";

// Distributor interface for state queries
interface IDistributor {
    function minPeriod() external view returns (uint256);
    function minDistribution() external view returns (uint256);
}

contract GMTdogeTest is Test {
    GMTdoge token;
    address owner = makeAddr("owner");
    address routerAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address factoryAddr = makeAddr("factory");
    address pairAddr = makeAddr("pair");

    function setUp() public {
        // Setup router and factory mock calls
        vm.mockCall(
            routerAddr,
            abi.encodeWithSignature("factory()"),
            abi.encode(factoryAddr)
        );
        vm.mockCall(
            factoryAddr,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(pairAddr)
        );

        // Deploy token
        vm.prank(owner);
        token = new GMTdoge();
    }

    function testDistributorSettingsValidation() public {
        console.log("--- Trigger Valid setDistributorSettings(749999) ---");
        vm.prank(owner);
        token.setDistributorSettings(749999);
        
        console.log("--- Trigger Invalid setDistributorSettings(750000) ---");
        vm.prank(owner);
        vm.expectRevert();
        token.setDistributorSettings(750000);
        
        console.log("Vulnerability not Exist: Distributor validation reverts properly");
    }

    function testSwapBackSettingsValidation() public {
        // Pre-trigger state
        bool swapEnabledBefore = token.swapEnabled();
        uint256 swapThresholdBefore = token.swapThreshold();
        
        console.log("--- BEFORE setSwapBackSettings ---");
        console.log("swapEnabled:", swapEnabledBefore);
        console.log("swapThreshold:", swapThresholdBefore);

        // Trigger setting max threshold
        console.log("--- Trigger setSwapBackSettings(max) ---");
        vm.prank(owner);
        token.setSwapBackSettings(true, type(uint256).max);

        // Post-trigger state
        console.log("--- AFTER setSwapBackSettings ---");
        bool swapEnabledAfter = token.swapEnabled();
        uint256 swapThresholdAfter = token.swapThreshold();
        console.log("swapEnabled:", swapEnabledAfter);
        console.log("swapThreshold:", swapThresholdAfter);

        // Vulnerability verification
        bool vulnerable = swapThresholdAfter == type(uint256).max;
        if (vulnerable) {
            console.log("Vulnerability Exists: Unsafe swap threshold accepted");
        } else {
            console.log("Vulnerability not Exist: Proper restrictions exist");
        }
    }

    function testAutoBuybackSettingsValidation() public {
        // Pre-trigger state - only checking available getters
        bool enabledBefore = token.autoBuybackEnabled();
        console.log("--- BEFORE setAutoBuybackSettings ---");
        console.log("autoBuybackEnabled:", enabledBefore);

        // Trigger vulnerability
        console.log("--- Trigger setAutoBuybackSettings(max) ---");
        vm.prank(owner);
        token.setAutoBuybackSettings(
            true, 
            type(uint256).max,
            type(uint256).max,
            type(uint256).max,
            true
        );

        // Post-trigger state
        console.log("--- AFTER setAutoBuybackSettings ---");
        bool enabledAfter = token.autoBuybackEnabled();
        console.log("autoBuybackEnabled:", enabledAfter);

        // Vulnerability verification - if all settings applied without revert
        if (enabledAfter) {
            console.log("Vulnerability Exists: Unsafe buyback settings accepted");
        } else {
            console.log("Vulnerability not Exist: Proper restrictions exist");
        }
    }

    function testDistributionCriteriaValidation() public {
        // Get distributor
        address distributorAddr = token.distributor();
        require(distributorAddr != address(0), "Distributor not set");
        IDistributor distributor = IDistributor(distributorAddr);

        // Pre-trigger state
        uint256 minPeriodBefore = distributor.minPeriod();
        uint256 minDistributionBefore = distributor.minDistribution();
        console.log("--- BEFORE setDistributionCriteria ---");
        console.log("MinPeriod:", minPeriodBefore);
        console.log("MinDistribution:", minDistributionBefore);

        // Trigger vulnerability
        console.log("--- Trigger setDistributionCriteria(max) ---");
        vm.prank(owner);
        token.setDistributionCriteria(type(uint256).max, type(uint256).max);

        // Post-trigger state
        console.log("--- AFTER setDistributionCriteria ---");
        uint256 minPeriodAfter = distributor.minPeriod();
        uint256 minDistributionAfter = distributor.minDistribution();
        console.log("MinPeriod:", minPeriodAfter);
        console.log("MinDistribution:", minDistributionAfter);

        // Vulnerability verification
        bool vulnerable = minPeriodAfter == type(uint256).max && 
                          minDistributionAfter == type(uint256).max;
        if (vulnerable) {
            console.log("Vulnerability Exists: Unsafe distribution criteria accepted");
        } else {
            console.log("Vulnerability not Exist: Proper restrictions exist");
        }
    }
}