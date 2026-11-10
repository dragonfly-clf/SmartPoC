// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Ordo_Chain.sol";

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0x111);
    }
}

contract MockRouter {
    address public immutable factoryAddr;
    
    constructor(address _factory) {
        factoryAddr = _factory;
    }
    
    function factory() external view returns (address) {
        return factoryAddr;
    }
}

contract Ordo_ChainTest is Test {
    Ordo_Chain token;
    address owner = address(0xABC123);
    address user1 = address(0xDEF456);
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint8 decimals;
    uint256 testTransferAmount;

    function setUp() public {
        // Deploy mock factory and router
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory));
        
        // Set router address to mock router implementation
        vm.etch(ROUTER, address(mockRouter).code);

        // Deploy token contract
        vm.startPrank(owner);
        token = new Ordo_Chain();
        decimals = token.decimals();
        uint256 initialBalance = 1000 * (10 ** decimals);
        token.transfer(user1, initialBalance);
        testTransferAmount = 100 * (10 ** decimals);
        vm.stopPrank();
    }

    function testExcessiveFee_causesTransferFailure() public {
        console.log("--- BEFORE-Trigger State ---");
        console.log("Original contract state active");

        console.log("--- Trigger: setTax(200) ---");
        vm.prank(owner);
        token.setTax(200);
        
        console.log("--- AFTER-Trigger Action ---");
        console.log("About to trigger vulnerable transfer");
        
        console.log("--- Trigger: transfer(0x111) ---");
        vm.prank(user1);
        vm.expectRevert("SafeMath: subtraction overflow");
        token.transfer(address(0x111), testTransferAmount);
        
        console.log("Vulnerability Exists: Setting tax to 200% causes subtraction overflow in transfers");
    }

    function testZeroTaxDivider_causesDivisionError() public {
        console.log("--- BEFORE-Trigger State ---");
        console.log("Original contract state active");
        
        console.log("--- Trigger: setTaxDivider(0) ---");
        vm.prank(owner);
        token.setTaxDivider(0);
        
        console.log("--- AFTER-Trigger Action ---");
        console.log("About to trigger vulnerable transfer");
        
        console.log("--- Trigger: transfer(0x111) ---");
        vm.prank(user1);
        vm.expectRevert("SafeMath: division by zero");
        token.transfer(address(0x111), testTransferAmount);
        
        console.log("Vulnerability Exists: Setting tax divider to 0 causes division by zero in transfers");
    }
}