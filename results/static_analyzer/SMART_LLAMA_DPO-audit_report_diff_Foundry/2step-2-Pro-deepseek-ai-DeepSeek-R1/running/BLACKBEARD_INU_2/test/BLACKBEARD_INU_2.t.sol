// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BLACKBEARD_INU.sol";

// Define mock contracts at the top level
contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xD111);
    }
}

contract MockRouter {
    address public factory;
    constructor(address _factory) {
        factory = _factory;
    }
}

contract BLACKBEARDInuTest is Test {
    BLACKBEARD_INU token;
    address owner;
    address constant HARDCODED_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    function setUp() public {
        owner = makeAddr("owner");
        
        // Deploy mock factory
        MockFactory mockFactory = new MockFactory();
        
        // Set code at hardcoded router address using deployed mock router
        MockRouter mockRouter = new MockRouter(address(mockFactory));
        bytes memory mockCode = address(mockRouter).code;
        vm.etch(HARDCODED_ROUTER, mockCode);
        
        // Explicitly set factory in router storage (slot 0)
        vm.store(
            HARDCODED_ROUTER, 
            bytes32(uint256(0)),
            bytes32(uint256(uint160(address(mockFactory))))
        );

        // Deploy contract as owner
        vm.startPrank(owner);
        token = new BLACKBEARD_INU();
        vm.stopPrank();
    }

    // Verify liquidity targets can be set without validation
    function testSetTargetLiquidityDangerousValues() public {
        console.log("--- BEFORE-Trigger ---");
        console.log("Preparing to call setTargetLiquidity with dangerous arguments...");

        bool firstCallSuccess;
        bool secondCallSuccess;

        console.log("--- Trigger 1: setTargetLiquidity(1000, 0) ---");
        vm.startPrank(owner);
        try token.setTargetLiquidity(1000, 0) {
            console.log("SetTargetLiquidity(1000,0) executed successfully");
            firstCallSuccess = true;
        } catch {
            console.log("SetTargetLiquidity(1000,0) reverted");
            firstCallSuccess = false;
        }

        console.log("--- Trigger 2: setTargetLiquidity(max,1) ---");
        try token.setTargetLiquidity(type(uint256).max, 1) {
            console.log("SetTargetLiquidity(max,1) executed successfully");
            secondCallSuccess = true;
        } catch {
            console.log("SetTargetLiquidity(max,1) reverted");
            secondCallSuccess = false;
        }
        vm.stopPrank();

        console.log("--- AFTER-Trigger Verdict ---");
        if (firstCallSuccess || secondCallSuccess) {
            console.log("Vulnerability Exists: At least one dangerous liquidity target setting succeeded");
        } else {
            console.log("Vulnerability not Exist: All dangerous calls reverted");
        }
    }

    // Verify buyback multiplier length isn't bounded
    function testSetBuybackMultiplierDangerousLength() public {
        console.log("--- BEFORE-Trigger ---");
        console.log("Preparing to call setBuybackMultiplierSettings with dangerous length...");

        bool callSuccess;

        console.log("--- Trigger: setBuybackMultiplierSettings(2,1,max) ---");
        vm.startPrank(owner);
        try token.setBuybackMultiplierSettings(2, 1, type(uint256).max) {
            console.log("SetBuybackMultiplierSettings executed successfully");
            callSuccess = true;
        } catch {
            console.log("SetBuybackMultiplierSettings reverted");
            callSuccess = false;
        }
        vm.stopPrank();

        console.log("--- AFTER-Trigger Verdict ---");
        if (callSuccess) {
            console.log("Vulnerability Exists: Buyback multiplier with dangerous length accepted");
        } else {
            console.log("Vulnerability not Exist: Dangerous length parameter reverted");
        }
    }
}