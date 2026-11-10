// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Independent.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xBEEF);
    }
}

contract MockRouter {
    address public immutable factory;
    
    constructor(address _factory) {
        factory = _factory;
    }
}

contract IndependentTest is Test {
    Independent public token;
    address constant REAL_ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    struct FeeState {
        uint256 liquidityFee;
        uint256 charityFee;
        uint256 marketingFee;
        uint256 projectFee;
        uint256 buyBackFee;
        uint256 totalFee;
        uint256 feeDenominator;
        uint256 logCount;
    }

    function setUp() public {
        // Deploy mock contracts
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory));
        
        // Inject mock router code at PancakeSwap address
        bytes memory routerCode = address(mockRouter).code;
        vm.etch(REAL_ROUTER_ADDR, routerCode);
        
        // Deploy token contract
        token = new Independent();
    }

    function test_setFeesEmitsNoEvents() public {
        console.log("--- BEFORE-Trigger setFees ---");
        FeeState memory before;
        before.liquidityFee = token.liquidityFee();
        before.charityFee = token.charityFee();
        before.marketingFee = token.marketingFee();
        before.projectFee = token.projectFee();
        before.buyBackFee = token.buyBackFee();
        before.totalFee = token.totalFee();
        before.feeDenominator = token.feeDenominator();
        before.logCount = vm.getRecordedLogs().length;
        
        console.log("State (before):");
        console.log("Liquidity fee:", before.liquidityFee);
        console.log("Log count:", before.logCount);

        console.log("--- Trigger setFees Operation ---");
        token.setFees(1, 2, 3, 4, 5, 100);

        console.log("--- AFTER-Trigger setFees ---");
        FeeState memory afterState;
        afterState.liquidityFee = token.liquidityFee();
        afterState.charityFee = token.charityFee();
        afterState.marketingFee = token.marketingFee();
        afterState.projectFee = token.projectFee();
        afterState.buyBackFee = token.buyBackFee();
        afterState.totalFee = token.totalFee();
        afterState.feeDenominator = token.feeDenominator();
        afterState.logCount = vm.getRecordedLogs().length;
        
        console.log("State (after):");
        console.log("Liquidity fee:", afterState.liquidityFee);
        console.log("Log count:", afterState.logCount);
        
        bool eventNotEmitted = (afterState.logCount == before.logCount);
        bool stateChanged = 
            afterState.liquidityFee == 1 &&
            afterState.charityFee == 2 &&
            afterState.marketingFee == 3 &&
            afterState.projectFee == 4 &&
            afterState.buyBackFee == 5 &&
            afterState.totalFee == 15 &&
            afterState.feeDenominator == 100;
        
        // Vulnerability verdict logic
        if (eventNotEmitted && stateChanged) {
            console.log("Vulnerability Exists: State changes implemented without events");
        } else if (!eventNotEmitted) {
            console.log("Vulnerability not Exist: Events were emitted during operation");
        } else {
            console.log("Vulnerability not Exist: Incorrect state changes detected");
        }
    }
}