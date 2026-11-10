// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/APTD.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234); // Return dummy pair address
    }
}

contract MockRouter {
    address immutable factoryAddr;
    
    constructor(address _factoryAddr) {
        factoryAddr = _factoryAddr;
    }
    
    function factory() external view returns (address) {
        return factoryAddr;
    }

    function WETH() external pure returns (address) {
        return address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    }
}

contract APTDFeeManipulationTest is Test {
    APTD aptd;
    address owner = address(0x1);
    
    function setUp() public {
        // Setup mainnet router address (0x10ED43...)
        address mainnetRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        
        // Deploy mock factory and get its code
        MockFactory mockFactory = new MockFactory();
        bytes memory factoryCode = address(mockFactory).code;
        
        // Deploy mock router using factory address
        MockRouter mockRouter = new MockRouter(address(mockFactory));
        bytes memory routerCode = address(mockRouter).code;
        
        // Use foundry cheatcode to simulate contracts at hardcoded addresses
        vm.etch(mainnetRouter, routerCode);
        
        // Set mainnet WBNB address for consistency
        address wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        vm.etch(wbnb, "0x00"); // Minimal initialization
        
        // Now deploy APTD contract as owner
        vm.startPrank(owner);
        aptd = new APTD();
        vm.stopPrank();
    }

    // Helper function to test buy fee updates
    function executeUpdateBuyFees(uint256 _devFee, uint256 _liquidityFee) external {
        vm.prank(owner);
        aptd.updateBuyFees(_devFee, _liquidityFee);
    }

    // Helper function to test sell fee updates
    function executeUpdateSellFees(uint256 _devFee, uint256 _liquidityFee) external {
        vm.prank(owner);
        aptd.updateSellFees(_devFee, _liquidityFee);
    }

    function testBuyFeeExceedsLimit() public {
        console.log("--- BEFORE-Trigger ---");
        console.log("Testing: Attempt to set buy fee > 50% (51%,0%)");

        console.log("--- Trigger: updateBuyFees(51,0) ---");
        bool success;
        try this.executeUpdateBuyFees(51, 0) {
            success = true;
        } catch (bytes memory) {
            success = false;
        }

        console.log("--- AFTER-Trigger ---");
        if (success) {
            console.log("State Change: Buy fee changed to 51%+0% (Total 51%)");
            console.log("Vulnerability Exists: Transaction succeeded in setting buy fee above 50%");
        } else {
            console.log("State Change: Update reverted - buy fee unchanged");
            console.log("Vulnerability not Exist: Fee capped at or below 50%");
        }
    }
    
    function testSellFeeExceedsLimit() public {
        console.log("--- BEFORE-Trigger ---");
        console.log("Testing: Attempt to set sell fee > 50% (60%,5%)");

        console.log("--- Trigger: updateSellFees(60,5) ---");
        bool success;
        try this.executeUpdateSellFees(60, 5) {
            success = true;
        } catch (bytes memory) {
            success = false;
        }

        console.log("--- AFTER-Trigger ---");
        if (success) {
            console.log("State Change: Sell fee changed to 60%+5% (Total 65%)");
            console.log("Vulnerability Exists: Transaction succeeded in setting sell fee above 50%");
        } else {
            console.log("State Change: Update reverted - sell fee unchanged");
            console.log("Vulnerability not Exist: Fee capped at or below 50%");
        }
    }
}