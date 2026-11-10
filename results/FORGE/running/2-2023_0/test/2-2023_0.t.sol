// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/bsc.sol";

contract MockWETH {
    function deposit() public payable {}
    function transfer(address, uint256) public pure returns (bool) {
        return true;
    }
    function withdraw(uint) public {}
}

contract MockPair { }

contract MockFactory {
    address public immutable pair;

    constructor(address _pair) {
        pair = _pair;
    }

    function createPair(address, address) external view returns (address) {
        return pair;
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

contract BSCTaxTest is Test {
    bsc token;

    function setUp() public {
        // Deploy mock contracts
        MockWETH mockWETH = new MockWETH();
        MockPair mockPair = new MockPair();
        MockFactory mockFactory = new MockFactory(address(mockPair));
        
        // Create mock router at fixed pancake address
        MockRouter mockRouter = new MockRouter(address(mockFactory), address(mockWETH));
        address pancakeAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        
        // Patch the hardcoded router address with our mock
        vm.etch(pancakeAddr, address(mockRouter).code);
        
        // Deploy token contract (test contract becomes owner)
        token = new bsc();
    }

    function testSetHighFees() public {
        console.log("--- BEFORE-Trigger Taxes ---");
        uint256 initialBuyTax = token._totalTaxIfBuying();
        uint256 initialSellTax = token._totalTaxIfSelling();
        console.log("Initial buy tax:", initialBuyTax, "%");
        console.log("Initial sell tax:", initialSellTax, "%");

        console.log("--- Trigger SetBuyTaxes and SetSellTaxes ---");
        // Owner (test contract) sets taxes exceeding 25% limit
        token.setBuyTaxes(15, 10, 10);   // Total 35%
        token.setSellTaxes(15, 15, 10);  // Total 40%

        console.log("--- AFTER-Trigger Taxes ---");
        uint256 newBuyTax = token._totalTaxIfBuying();
        uint256 newSellTax = token._totalTaxIfSelling();
        console.log("New buy tax:", newBuyTax, "%");
        console.log("New sell tax:", newSellTax, "%");

        // Check if taxes exceed 25% cap
        if (newBuyTax > 25 || newSellTax > 25) {
            console.log("Vulnerability Exists: Tax rates exceed 25%% limit");
        } else {
            console.log("Vulnerability not Exist: Tax rates remain within 25%% limit");
        }
    }
}