// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CryptoFighter.sol";

contract MockStaticRouter {
    function factory() external pure returns (address) {
        return address(0x123);
    }

    function WETH() external pure returns (address) {
        return address(0x456);
    }
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0x789);
    }
}

contract CryptoFighterFeeTest is Test {
    CryptoFighter token;
    address owner = makeAddr("owner");
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant FACTORY = address(0x123);

    function setUp() public {
        // Deploy mock router implementation
        MockStaticRouter mockRouterImpl = new MockStaticRouter();
        // Set mock router code at router address
        vm.etch(ROUTER, address(mockRouterImpl).code);
        
        // Deploy mock factory implementation
        MockFactory mockFactoryImpl = new MockFactory();
        // Set mock factory code at factory address
        vm.etch(FACTORY, address(mockFactoryImpl).code);

        // Deploy token contract as owner
        vm.prank(owner);
        token = new CryptoFighter();
    }

    function testTaxFeeManipulation() public {
        uint256 excessiveTaxFee = 30;
        uint256 safeFeeLimit = 25;

        console.log("--- BEFORE-Trigger TaxFee Query ---");
        uint256 initialTaxFee = token._taxFee();
        console.log("Initial Tax Fee (%):", initialTaxFee);

        console.log("--- Trigger SetTaxFeePercent ---");
        // Verify owner can set tax fee beyond implied 25% limit
        vm.prank(owner);
        token.setTaxFeePercent(excessiveTaxFee);
        
        console.log("--- AFTER-Trigger TaxFee Query ---");
        uint256 currentTaxFee = token._taxFee();
        console.log("Current Tax Fee After Action (%):", currentTaxFee);

        // Final vulnerability verification
        if (currentTaxFee == excessiveTaxFee) {
            console.log("Vulnerability Exists: Owner can set tax fee to 30% exceeding 25% limit");
        } else if (currentTaxFee > safeFeeLimit) {
            console.log("Vulnerability Exists: Tax fee set to", currentTaxFee, "% exceeding 25% safe limit");
        } else {
            console.log("Vulnerability not Exist: Tax fee configuration is secure");
        }
    }
}