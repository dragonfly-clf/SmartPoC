// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Ordo_Chain.sol";

contract MockRouter {
    address public factory;
    
    constructor(address _factory) {
        factory = _factory;
    }
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0x10);
    }
}

contract MockWBNB {}

contract FeeManipulationTest is Test {
    Ordo_Chain token;
    TaxPool taxPool;
    
    address constant owner = address(0x1);
    address constant user = address(0x2);
    address constant routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant wbnbAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function setUp() public {
        // Deploy dependencies
        MockFactory factory = new MockFactory();
        MockRouter tempRouter = new MockRouter(address(factory));
        
        // Set up router
        vm.etch(routerAddress, address(tempRouter).code);
        // Prepare value for storage
        address factoryAddress = address(factory);
        bytes32 value = bytes32(uint256(uint160(factoryAddress)));
        vm.store(
            routerAddress, 
            bytes32(0), // factory storage slot
            value
        );
        
        // Mock WBNB contract
        vm.etch(wbnbAddress, type(MockWBNB).creationCode);

        // Deploy main contracts
        vm.prank(owner);
        token = new Ordo_Chain();
        
        taxPool = new TaxPool();
        taxPool.transferOwnership(address(token));
        
        vm.prank(owner);
        token.setTaxPool(address(taxPool));
    }

    function test_marketing_tax_can_exceed_25_percent() public {
        uint256 excessTaxPercentage = 30; // Above 25% limit
        
        console.log("--- BEFORE-Trigger marketingPercentage ---");
        uint256 initialMarketingPercentage = taxPool.marketingPercentage();
        console.log("Initial marketing tax percentage:", initialMarketingPercentage);

        console.log("--- Trigger: setMarketingTax with 30% ---");
        vm.prank(owner);
        token.setMarketingTax(excessTaxPercentage, user);
        
        console.log("--- AFTER-Trigger marketingPercentage ---");
        uint256 newMarketingPercentage = taxPool.marketingPercentage();
        console.log("Updated marketing tax percentage:", newMarketingPercentage);
        
        console.log("--- Comparison Verdict ---");
        bool hasChanged = (newMarketingPercentage != initialMarketingPercentage);
        bool isSetCorrectly = (newMarketingPercentage == excessTaxPercentage);
        console.log("State changed:", hasChanged ? "YES" : "NO");
        console.log("Set to desired value (30%):", isSetCorrectly ? "YES" : "NO");
        console.log("Exploitation successful:", (hasChanged && isSetCorrectly) ? "YES" : "NO");
        
        if (hasChanged && isSetCorrectly) {
            console.log("Vulnerability Exists: Marketing tax can be set above 25% limit");
        } else {
            console.log("Vulnerability not Exist: Marketing tax respects 25% limit");
        }
    }
}