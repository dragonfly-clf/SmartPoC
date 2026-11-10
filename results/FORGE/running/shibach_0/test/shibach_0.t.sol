// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ShibaChristmas.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xDEAD);
    }
}

contract MockRouter {
    address public factory;
    address public WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract ShibaChristmasFeeTest is Test {
    ShibaChristmas token;
    address constant weth = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant pancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant ownerAddr = 0xBd3205731C73B207E95b46fA6639dD5A4ABF7E41;

    function setUp() public {
        vm.startPrank(ownerAddr);
        
        // Deploy mocks
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory), weth);
        
        // Set up target router address with mock bytecode
        vm.etch(pancakeRouter, address(mockRouter).code);
        
        // Initialize router storage - public variables use storage slots
        // factory is slot 0, WETH is slot 1
        vm.store(pancakeRouter, bytes32(uint256(0)), bytes32(uint256(uint160(address(mockFactory))))); // factory
        vm.store(pancakeRouter, bytes32(uint256(1)), bytes32(uint256(uint160(weth)))); // WETH
        
        // Deploy actual token contract that uses mocked router
        token = new ShibaChristmas();
        vm.stopPrank();
    }

    function testExcessiveFeeSetting() public {
        // Impersonate token owner
        vm.startPrank(ownerAddr);
        
        console.log("--- BEFORE-Trigger: Initial state ---");
        uint256 initialDevFee = token._developmentFee();
        console.log("Initial development fee:", initialDevFee, "%");
        
        console.log("--- Trigger: setDevelopmentFeePercent(100) ---");
        token.setDevelopmentFeePercent(100);
        
        console.log("--- AFTER-Trigger (first fee change) ---");
        uint256 devFeeAfter100 = token._developmentFee();
        console.log("Development fee after first change:", devFeeAfter100, "%");
        assertEq(devFeeAfter100, 100, "Fee should be set to 100%");
        
        console.log("--- BEFORE-Trigger (second fee change) ---");
        uint256 currentFeeBeforeSecond = token._developmentFee();
        console.log("Development fee before second change:", currentFeeBeforeSecond, "%");
        
        console.log("--- Trigger: setDevelopmentFeePercent(9001) ---");
        token.setDevelopmentFeePercent(9001);
        
        console.log("--- AFTER-Trigger (second fee change) ---");
        uint256 devFeeAfter9001 = token._developmentFee();
        console.log("Development fee after second change:", devFeeAfter9001, "%");
        assertEq(devFeeAfter9001, 9001, "Fee should be set to 9001%");
        
        // Final vulnerability verdict
        if (devFeeAfter9001 == 9001) {
            console.log("Vulnerability Exists: Owner can set development fee to 9001% which is excessive");
        } else {
            console.log("Vulnerability not Exist: Development fee cannot be set to 9001%");
        }
        
        vm.stopPrank();
    }
}