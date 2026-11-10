// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FutuballToken.sol";

contract MockWETH {
    // Minimal WETH implementation
}

contract MockFactory {
    function createPair(address, address) external returns (address pair) {
        return address(0x123); // Return dummy pair address
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable weth;

    constructor(address factory_, address weth_) {
        factory = factory_;
        weth = weth_;
    }

    function WETH() external view returns (address) {
        return weth;
    }
}

contract FutuballTokenTaxTest is Test {
    FutuballToken private token;
    address private constant OWNER = address(0x1);
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Create mocks
        MockWETH weth = new MockWETH();
        MockFactory factory = new MockFactory();
        MockRouter routerImpl = new MockRouter(address(factory), address(weth));
        
        // Etch mock router implementation into fixed address
        vm.etch(ROUTER_ADDRESS, address(routerImpl).code);
        
        // Deploy token as owner
        vm.startPrank(OWNER);
        token = new FutuballToken();
        vm.stopPrank();
    }

    function test_OwnerCanSetTaxBeyond100Percent() public {
        console.log("--- BEFORE-Trigger TaxFee ---");
        // Record initial tax rates (note: contract initializes with 5% fees)
        uint256 initialSellTax = token.sellTaxFee();
        uint256 initialBuyTax = token.buyTaxFee();
        console.log("Initial sell tax (basis points):", initialSellTax);
        console.log("Initial buy tax (basis points):", initialBuyTax);

        console.log("--- Trigger setTax ---");
        uint256 excessiveFee = 10001; // 100.01% in basis points
        vm.prank(OWNER);
        token.setTax(excessiveFee, excessiveFee);
        console.log("Called setTax(10001, 10001) as owner");

        console.log("--- AFTER-Trigger TaxFee ---");
        // Record updated tax rates
        uint256 newSellTax = token.sellTaxFee();
        uint256 newBuyTax = token.buyTaxFee();
        console.log("New sell tax (basis points):", newSellTax);
        console.log("New buy tax (basis points):", newBuyTax);

        // Vulnerability check: verify taxes set above 100% (10000 basis points)
        bool vulnerabilityExists = (newSellTax > 10000) || (newBuyTax > 10000);
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Tax rates can be set beyond 100% limit");
        } else {
            console.log("Vulnerability not Exist: Tax rates cannot exceed 100% limit");
        }
    }
}