// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Munkai.sol";

contract MockDEXFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0);
    }
}

contract MockDEXRouter {
    address public factory;
    address public immutable WETH;

    constructor() {
        factory = address(new MockDEXFactory());
        WETH = address(1234);
    }
}

interface DividendDistributor {
    function minPeriod() external view returns (uint256);
    function minDistribution() external view returns (uint256);
}

contract MunkaiTest is Test {
    Munkai public token;
    MockDEXRouter public router;
    address owner;
    address authorizedUser = address(0x1);
    address unauthorizedUser = address(0x2);
    DividendDistributor public distributor;

    function setUp() public {
        owner = address(this);
        router = new MockDEXRouter();
        token = new Munkai(address(router));
        
        // Add an authorized user
        token.authorize(authorizedUser);
        
        distributor = DividendDistributor(token.distributorAddress());
    }

    // Test for setDistributorSettings function (access control)
    function test_setDistributorSettings_AccessControl() public {
        // Unauthorized user should fail
        vm.prank(unauthorizedUser);
        vm.expectRevert("!AUTHORIZED");
        token.setDistributorSettings(100000);

        // Authorized user should succeed - state not verifiable
        vm.prank(authorizedUser);
        token.setDistributorSettings(100000);
        
        console.log("Vulnerability not Exist: Unauthorized access prevented, state not observable");
    }

    // Test for setDistributorSettings function (parameter validation)
    function test_setDistributorSettings_ParameterValidation() public {
        // Should revert if >= 750000
        vm.expectRevert();
        token.setDistributorSettings(750000);

        // Should work with < 750000 - state not verifiable
        token.setDistributorSettings(749999);
        
        console.log("Vulnerability not Exist: Reversion on invalid parameter");
    }

    // Test for setTargetLiquidity function (with state checks)
    function test_setTargetLiquidity_AccessControl() public {
        console.log("--- BEFORE unauthorized setTargetLiquidity ---");
        uint256 initTarget = token.targetLiquidity();
        uint256 initDenom = token.targetLiquidityDenominator();
        console.log("Initial targetLiquidity:", initTarget);
        console.log("Initial targetLiquidityDenominator:", initDenom);

        console.log("--- Trigger unauthorized setTargetLiquidity ---");
        vm.prank(unauthorizedUser);
        vm.expectRevert("!AUTHORIZED");
        token.setTargetLiquidity(100, 100);

        console.log("--- AFTER unauthorized setTargetLiquidity ---");
        uint256 currentTarget = token.targetLiquidity();
        uint256 currentDenom = token.targetLiquidityDenominator();
        console.log("Current targetLiquidity:", currentTarget);
        console.log("Current targetLiquidityDenominator:", currentDenom);
        
        bool unauthorizedChanged = (initTarget != currentTarget) || (initDenom != currentDenom);
        console.log("Unauthorized state change:", unauthorizedChanged ? "Yes - VULN" : "No - Secure");
        
        console.log("--- BEFORE authorized setTargetLiquidity ---");
        initTarget = token.targetLiquidity();
        initDenom = token.targetLiquidityDenominator();
        console.log("Initial targetLiquidity:", initTarget);
        console.log("Initial targetLiquidityDenominator:", initDenom);

        console.log("--- Trigger authorized setTargetLiquidity ---");
        vm.prank(authorizedUser);
        token.setTargetLiquidity(100, 100);

        console.log("--- AFTER authorized setTargetLiquidity ---");
        currentTarget = token.targetLiquidity();
        currentDenom = token.targetLiquidityDenominator();
        console.log("Current targetLiquidity:", currentTarget);
        console.log("Current targetLiquidityDenominator:", currentDenom);
        
        bool stateChanged = (currentTarget == 100) && (currentDenom == 100);
        console.log("Authorized state change:", stateChanged ? "Expected" : "Unexpected");

        if (unauthorizedChanged) {
            console.log("Vulnerability Exists: Unauthorized change to liquidity settings");
        } else {
            console.log("Vulnerability not Exist: Unauthorized access prevented");
        }
    }

    // Test for setSwapBackSettings function (with state checks)
    function test_setSwapBackSettings_AccessControl() public {
        console.log("--- BEFORE unauthorized setSwapBackSettings ---");
        bool initialSwapEnabled = token.swapEnabled();
        uint256 initialSwapThreshold = token.swapThreshold();
        console.log("Initial swapEnabled:", initialSwapEnabled);
        console.log("Initial swapThreshold:", initialSwapThreshold);

        console.log("--- Trigger unauthorized setSwapBackSettings ---");
        vm.prank(unauthorizedUser);
        vm.expectRevert("!AUTHORIZED");
        token.setSwapBackSettings(true, 100);

        console.log("--- AFTER unauthorized setSwapBackSettings ---");
        bool currentSwapEnabled = token.swapEnabled();
        uint256 currentSwapThreshold = token.swapThreshold();
        console.log("Current swapEnabled:", currentSwapEnabled);
        console.log("Current swapThreshold:", currentSwapThreshold);
        
        bool unauthorizedChanged = (initialSwapEnabled != currentSwapEnabled) || 
                                   (initialSwapThreshold != currentSwapThreshold);
        console.log("Unauthorized state change:", unauthorizedChanged ? "Yes - VULN" : "No - Secure");
        
        console.log("--- BEFORE authorized setSwapBackSettings ---");
        initialSwapEnabled = token.swapEnabled();
        initialSwapThreshold = token.swapThreshold();
        console.log("Initial swapEnabled:", initialSwapEnabled);
        console.log("Initial swapThreshold:", initialSwapThreshold);

        console.log("--- Trigger authorized setSwapBackSettings ---");
        vm.prank(authorizedUser);
        token.setSwapBackSettings(true, 100);

        console.log("--- AFTER authorized setSwapBackSettings ---");
        currentSwapEnabled = token.swapEnabled();
        currentSwapThreshold = token.swapThreshold();
        console.log("Current swapEnabled:", currentSwapEnabled);
        console.log("Current swapThreshold:", currentSwapThreshold);
        
        bool stateChanged = (currentSwapEnabled == true) && (currentSwapThreshold == 100);
        console.log("Authorized state change:", stateChanged ? "Expected" : "Unexpected");

        if (unauthorizedChanged) {
            console.log("Vulnerability Exists: Unauthorized change to swap settings");
        } else {
            console.log("Vulnerability not Exist: Unauthorized access prevented");
        }
    }

    // Test for setDistributionCriteria function (with state checks)
    function test_setDistributionCriteria_AccessControl() public {
        console.log("--- BEFORE unauthorized setDistributionCriteria ---");
        uint256 initialMinPeriod = distributor.minPeriod();
        uint256 initialMinDistribution = distributor.minDistribution();
        console.log("Initial minPeriod:", initialMinPeriod);
        console.log("Initial minDistribution:", initialMinDistribution);

        console.log("--- Trigger unauthorized setDistributionCriteria ---");
        vm.prank(unauthorizedUser);
        vm.expectRevert("!AUTHORIZED");
        token.setDistributionCriteria(1 hours, 1 ether);

        console.log("--- AFTER unauthorized setDistributionCriteria ---");
        uint256 currentMinPeriod = distributor.minPeriod();
        uint256 currentMinDistribution = distributor.minDistribution();
        console.log("Current minPeriod:", currentMinPeriod);
        console.log("Current minDistribution:", currentMinDistribution);
        
        bool unauthorizedChanged = (initialMinPeriod != currentMinPeriod) || 
                                   (initialMinDistribution != currentMinDistribution);
        console.log("Unauthorized state change:", unauthorizedChanged ? "Yes - VULN" : "No - Secure");
        
        console.log("--- BEFORE authorized setDistributionCriteria ---");
        initialMinPeriod = distributor.minPeriod();
        initialMinDistribution = distributor.minDistribution();
        console.log("Initial minPeriod:", initialMinPeriod);
        console.log("Initial minDistribution:", initialMinDistribution);

        console.log("--- Trigger authorized setDistributionCriteria ---");
        vm.prank(authorizedUser);
        token.setDistributionCriteria(1 hours, 1 ether);

        console.log("--- AFTER authorized setDistributionCriteria ---");
        currentMinPeriod = distributor.minPeriod();
        currentMinDistribution = distributor.minDistribution();
        console.log("Current minPeriod:", currentMinPeriod);
        console.log("Current minDistribution:", currentMinDistribution);
        
        bool stateChanged = (currentMinPeriod == 1 hours) && 
                            (currentMinDistribution == 1 ether);
        console.log("Authorized state change:", stateChanged ? "Expected" : "Unexpected");

        if (unauthorizedChanged) {
            console.log("Vulnerability Exists: Unauthorized change to distribution criteria");
        } else {
            console.log("Vulnerability not Exist: Unauthorized access prevented");
        }
    }
}