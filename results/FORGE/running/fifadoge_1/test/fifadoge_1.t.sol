// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FIFADoge.sol";

contract MockWETH {
    function deposit() external payable {}
    function transfer(address, uint256) external pure returns (bool) { return true; }
    function approve(address, uint256) external pure returns (bool) { return true; }
}

contract MockPair {
    function sync() external {}
}

contract MockFactory {
    function getPair(address, address) external pure returns (address) {
        return address(0);
    }
    
    function createPair(address, address) external returns (address) {
        return address(new MockPair());
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    
    constructor() {
        factory = address(new MockFactory());
        WETH = address(new MockWETH());
    }
}

contract FIFADogeTest is Test {
    FIFADoge token;
    address owner = address(0x1);
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Deploy mock router at original address
        MockRouter mockRouter = new MockRouter();
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);

        // Deploy token contract as owner
        vm.startPrank(owner);
        token = new FIFADoge();
        vm.stopPrank();
    }

    function testSetExcessiveSellTaxes() public {
        // Pre-trigger state snapshot
        console.log("--- BEFORE-Trigger Taxes ---");
        uint256 initialTax;
        try token._totalTaxIfSelling() returns (uint256 tax) {
            initialTax = tax;
            console.log("Initial sell tax percentage:", initialTax);
        } catch {
            console.log("Error: Unable to read sell tax state");
            fail();
        }
        
        console.log("--- Trigger ChangeTaxes ---");
        // Owner sets sell taxes to 10000 for each category (10000%)
        vm.startPrank(owner);
        token.setSelTaxes(10000, 10000, 10000);
        vm.stopPrank();

        // Post-trigger state snapshot
        console.log("--- AFTER-Trigger Taxes ---");
        uint256 newTax;
        try token._totalTaxIfSelling() returns (uint256 tax) {
            newTax = tax;
            console.log("New sell tax percentage:", newTax);
        } catch {
            console.log("Error: Unable to read sell tax state after change");
            fail();
        }

        // Differential validation
        console.log("--- Differential Result ---");
        bool taxesChanged = newTax != initialTax;
        bool excessiveTaxSet = newTax == 30000; // 10000+10000+10000=30000%

        console.log("Taxes changed:", taxesChanged ? "YES" : "NO");
        console.log("Excessive tax set (30000%):", excessiveTaxSet ? "YES, Vulnerability Exist" : "NO, Vulnerability not Exist");
        
        if (excessiveTaxSet) {
            console.log("Vulnerability Exists: Owner can set taxes to 30000%%");
        } else {
            console.log("Vulnerability not Exist: Failed to set excessive taxes");
        }
    }
}