// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/XRPNATION.sol";

// Define distributor interface for state queries
interface IDistributor {
    function minPeriod() external view returns (uint256);
    function minDistribution() external view returns (uint256);
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0x111);
    }
}

contract XRPNATION_Test is Test {
    XRPNATION token;
    address owner = address(0x1);

    address constant FACTORY_ADDR = address(0x111);
    address constant ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Setup mocks
        vm.etch(FACTORY_ADDR, address(new MockFactory()).code);
        vm.etch(ROUTER_ADDR, address(new MockRouter()).code);

        // Deploy token contract
        vm.startPrank(owner);
        token = new XRPNATION();
        vm.stopPrank();
    }
    
    function test_setDistributionCriteria_NoValidation() public {
        // Use address to create IDistributor interface instance
        IDistributor distributor = IDistributor(address(token.distributor()));
        
        console.log("--- BEFORE-Trigger setDistributionCriteria(0,0) ---");
        uint256 minPeriodBefore = distributor.minPeriod();
        uint256 minDistributionBefore = distributor.minDistribution();
        console.log("Current minPeriod:", minPeriodBefore);
        console.log("Current minDistribution:", minDistributionBefore);
        
        console.log("--- Trigger setDistributionCriteria(0,0) ---");
        vm.prank(owner);
        token.setDistributionCriteria(0, 0);
        
        console.log("--- AFTER-Trigger setDistributionCriteria(0,0) ---");
        uint256 minPeriodAfter = distributor.minPeriod();
        uint256 minDistributionAfter = distributor.minDistribution();
        console.log("New minPeriod:", minPeriodAfter);
        console.log("New minDistribution:", minDistributionAfter);
        
        // Validate state change for first set
        bool firstSetSuccess = (minPeriodAfter == 0) && (minDistributionAfter == 0);
        console.log("Initial values set to zero:", firstSetSuccess ? "SUCCESS" : "FAILED");

        console.log("--- BEFORE-Trigger setDistributionCriteria(max) ---");
        minPeriodBefore = distributor.minPeriod();
        minDistributionBefore = distributor.minDistribution();
        console.log("Current minPeriod:", minPeriodBefore);
        console.log("Current minDistribution:", minDistributionBefore);
        
        console.log("--- Trigger setDistributionCriteria(max values) ---");
        uint256 largePeriod = 36525 days;
        uint256 largeDistribution = type(uint256).max;
        vm.prank(owner);
        token.setDistributionCriteria(largePeriod, largeDistribution);
        
        console.log("--- AFTER-Trigger setDistributionCriteria(max) ---");
        minPeriodAfter = distributor.minPeriod();
        minDistributionAfter = distributor.minDistribution();
        console.log("New minPeriod:", minPeriodAfter);
        console.log("New minDistribution:", minDistributionAfter);
        
        // Validate state change for second set
        bool secondSetSuccess = (minPeriodAfter == largePeriod) && 
                               (minDistributionAfter == largeDistribution);
        console.log("Large values correctly set:", secondSetSuccess ? "SUCCESS" : "FAILED");

        // Final vulnerability verdict
        if (firstSetSuccess && secondSetSuccess) {
            console.log("Vulnerability Exists: setDistributionCriteria allows arbitrary value changes without validation");
        } else {
            console.log("Vulnerability not Exist: Value changes were not executed as expected");
        }
    }
}