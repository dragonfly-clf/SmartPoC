// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Munkai.sol";

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123); // Return non-zero dummy address
    }
}

contract MunkaiTest is Test {
    Munkai token;
    address deployer = address(0x1);
    address authorizedUser = address(0x2);
    address constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function setUp() public {
        vm.startPrank(deployer);
        MockFactory factory = new MockFactory();
        MockRouter router = new MockRouter(address(factory), weth);
        token = new Munkai(address(router));
        
        token.authorize(authorizedUser);
        vm.stopPrank();
    }

    function testSetBuybackMultiplierSettings_ArbitraryValues() public {
        vm.startPrank(authorizedUser);

        console.log("--- BEFORE-Trigger: setBuybackMultiplierSettings ---");
        console.log("Pre-trigger state: No public state getter available for buybackMultiplierNumerator/denominator");
        
        console.log("--- Trigger: setBuybackMultiplierSettings(1000, 500, 1 days) ---");
        bool success;
        try token.setBuybackMultiplierSettings(1000, 500, 1 days) {
            success = true;
        } catch {
            success = false;
        }

        console.log("--- AFTER-Trigger: setBuybackMultiplierSettings ---");
        if (success) {
            console.log("Post-trigger state: Call succeeded without reverting");
            console.log("Vulnerability Exists: setBuybackMultiplierSettings accepted dangerous values without reverting");
        } else {
            console.log("Post-trigger state: Call reverted");
            console.log("Vulnerability not Exist: setBuybackMultiplierSettings reverted");
        }

        vm.stopPrank();
    }

    function testSetTargetLiquidity_DangerousValues() public {
        vm.startPrank(authorizedUser);

        console.log("--- BEFORE-Trigger: setTargetLiquidity ---");
        console.log("Pre-trigger state: No public state getter available for targetLiquidity");
        
        console.log("--- Trigger: setTargetLiquidity(100, 1) ---");
        bool success;
        try token.setTargetLiquidity(100, 1) {
            success = true;
        } catch {
            success = false;
        }

        console.log("--- AFTER-Trigger: setTargetLiquidity ---");
        if (success) {
            console.log("Post-trigger state: Call succeeded without reverting");
            console.log("Vulnerability Exists: setTargetLiquidity accepted dangerous values without reverting");
        } else {
            console.log("Post-trigger state: Call reverted");
            console.log("Vulnerability not Exist: setTargetLiquidity reverted");
        }

        vm.stopPrank();
    }
}