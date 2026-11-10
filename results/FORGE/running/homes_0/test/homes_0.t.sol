// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/HomesCoin.sol";

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0x1111111111111111111111111111111111111111);
    }

    function WETH() external pure returns (address) {
        return address(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270); // MATIC
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x2222222222222222222222222222222222222222);
    }
}

contract HomesCoinTest is Test {
    HomesCoin token;
    address owner = address(0xA);

    // Router and Factory addresses commonly used on Polygon
    address constant ROUTER = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;
    address constant FACTORY = 0x1111111111111111111111111111111111111111;

    function setUp() public {
        // Create mock contracts
        MockRouter router = new MockRouter();
        MockFactory factory = new MockFactory();
        
        // Override real contract addresses with mocks
        vm.etch(ROUTER, address(router).code);
        vm.etch(FACTORY, address(factory).code);

        // Deploy token contract as owner
        vm.startPrank(owner);
        token = new HomesCoin();
        vm.stopPrank();
    }

    function testFeeManipulation() public {
        // BEFORE-TRIGGER: Query initial state
        console.log("--- BEFORE-Trigger SetMarketingFeePercent ---");
        uint256 initialFee = token._marketingFee();
        console.log("Initial marketing fee percentage: %d", initialFee);

        // Check status BEFORE triggering vulnerability
        console.log("Executing attack actions...");
        console.log("--- TRIGGER: setMarketingFeePercent(9900)");
        vm.prank(owner);
        token.setMarketingFeePercent(9900);  // 99% fee

        console.log("--- TRIGGER: setMarketingFeePercent(10000)");
        vm.prank(owner);
        token.setMarketingFeePercent(10000); // 100% fee

        // AFTER-TRIGGER: Query final state
        console.log("--- AFTER-Trigger SetMarketingFeePercent ---");
        uint256 finalFee = token._marketingFee();
        console.log("Final marketing fee percentage: %d", finalFee);

        // Output differential results
        console.log(
            "Fee manipulation status: %s",
            finalFee == 10000 
                ? "SUCCESS (10000 = 100%)" 
                : string(abi.encodePacked("FAIL (", vm.toString(finalFee), " = ", vm.toString(finalFee/100), "%)"))
        );

        // Final vulnerability verdict
        if (finalFee == 10000) {
            console.log("Vulnerability Exists: Marketing fee can be set to dangerous 100%% level");
        } else {
            console.log("Vulnerability not Exist: Unable to set marketing fee to 100%%");
        }
    }
}