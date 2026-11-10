// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

// Mock contracts to simulate DEX environment
contract MockWETH {
    function deposit() public payable {}
    function transfer(address, uint256) public pure returns (bool) { return true; }
    function approve(address, uint256) public pure returns (bool) { return true; }
}

contract MockFactory {
    function createPair(address, address) public pure returns (address) {
        return address(0xabcd);
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

contract FeeManipulationTest is Test {
    CoinToken token;
    MockRouter public mockRouter;
    MockFactory public mockFactory;
    MockWETH public mockWETH;
    
    address owner = address(this);
    address feeAddr = address(0x123);
    address service = address(0x456);

    function setUp() public {
        // Deploy mock ecosystem
        mockWETH = new MockWETH();
        mockFactory = new MockFactory();
        mockRouter = new MockRouter(address(mockFactory), address(mockWETH));

        // Deploy token contract
        token = new CoinToken{value: 0}(
            "TestToken",
            "TT",
            18,     // decimals
            1e6,    // initial supply
            1,      // taxFee
            1,      // liquidityFee
            1,      // devFee
            address(mockRouter),
            feeAddr,
            owner,
            service
        );
    }

    function testSetTaxFeeManipulation() public {
        uint256[] memory targets = new uint256[](2);
        targets[0] = 26;
        targets[1] = 99;
        bool vulnerable = false;

        for (uint256 i = 0; i < targets.length; i++) {
            console.log("--- BEFORE-Trigger Change (tax fee) for Testcase", i+1, "---");
            uint256 preTaxFee = token._taxFee();
            console.log("Initial tax fee value:", preTaxFee);
            
            console.log("--- Trigger: setTaxFeePercent(%s) ---", targets[i]);
            token.setTaxFeePercent(targets[i]);

            console.log("--- AFTER-Trigger Change (tax fee) for Testcase", i+1, "---");
            uint256 postTaxFee = token._taxFee();
            console.log("New tax fee value:", postTaxFee);

            if (postTaxFee == targets[i] && postTaxFee > 25) {
                console.log("SUCCESS: Tax fee changed to", postTaxFee, "(exceeds 25% limit)");
                vulnerable = true;
            } else {
                console.log("FAIL: Tax fee not set correctly or within limit");
            }
        }

        if (vulnerable) {
            console.log("Vulnerability Exists: Owner can set tax fee above 25%");
        } else {
            console.log("Vulnerability not Exist: Tax fee change limit enforced");
        }
    }

    function testSetDevFeeManipulation() public {
        console.log("--- BEFORE-Trigger Change (dev fee) ---");
        uint256 preDevFee = token._devFee();
        console.log("Initial dev fee value:", preDevFee);
        
        console.log("--- Trigger: setDevFeePercent(26) ---");
        token.setDevFeePercent(26);

        console.log("--- AFTER-Trigger Change (dev fee) ---");
        uint256 postDevFee = token._devFee();
        console.log("New dev fee value:", postDevFee);

        if (postDevFee == 26 && postDevFee > 25) {
            console.log("SUCCESS: Dev fee changed to", postDevFee, "(exceeds 25% limit)");
            console.log("Vulnerability Exists: Owner can set dev fee above 25%");
        } else {
            console.log("Vulnerability not Exist: Dev fee change limit enforced");
        }
    }
}