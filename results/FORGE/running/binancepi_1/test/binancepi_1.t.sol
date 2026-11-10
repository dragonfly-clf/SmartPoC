// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BinancePi.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xabc);
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract BinancePiTaxTest is Test {
    BinancePi public token;
    
    function setUp() public {
        // Prepare mock environment
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        MockFactory mockFactory = new MockFactory();
        address weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        MockRouter mockRouter = new MockRouter(address(mockFactory), weth);

        // Mock the router address
        vm.etch(routerAddress, address(mockRouter).code);
        
        // Deploy token contract
        token = new BinancePi();
    }

    function test_SetSellTaxesExceedingLimit() public {
        // Get contract owner
        address owner = token.owner();
        
        console.log("--- BEFORE-Trigger State Snapshot ---");
        console.log("Note: Contract lacks public getters to verify tax rates");
        console.log("Intending to set sell taxes to 30% (10% each) which exceeds intended 15% limit");
        
        console.log("--- Trigger setSellTaxes ---");
        vm.startPrank(owner);
        (bool success, ) = address(token).call(
            abi.encodeWithSelector(token.setSellTaxes.selector, 10, 10, 10)
        );
        vm.stopPrank();
        if (success) {
            console.log("Transaction: did NOT revert");
        } else {
            console.log("Transaction: reverted");
        }
        
        console.log("--- AFTER-Trigger State Snapshot ---");
        console.log("Note: Tax rates still unverifiable via public getters");
        
        // Final verdict based on transaction success
        if (success) {
            console.log("Vulnerability Exists: Transaction succeeded when should revert for >15% taxes");
        } else {
            console.log("Vulnerability not Exist: Tax set reverted as expected");
        }
    }
}