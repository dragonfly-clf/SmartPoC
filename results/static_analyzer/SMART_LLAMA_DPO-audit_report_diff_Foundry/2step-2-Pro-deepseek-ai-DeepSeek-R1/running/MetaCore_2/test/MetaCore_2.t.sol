// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MetaCore.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234);
    }
}

contract MockUniswapV2Router {
    address public factory;

    constructor(address _factory) {
        factory = _factory;
    }

    function WETH() external pure returns (address) {
        return address(0x9);
    }
}

contract NonPayable {
    // Empty contract without receive/fallback functions
}

contract MetaCoreTest is Test {
    MetaCore token;
    address ownOwner = address(this);
    address initialMarketing = address(0x1);
    MockUniswapV2Router router;

    function setUp() public {
        MockUniswapV2Factory factory = new MockUniswapV2Factory();
        router = new MockUniswapV2Router(address(factory));
        token = new MetaCore(initialMarketing, 1, address(router));
    }

    function testUnvalidatedMarketingAddress() public {
        // Case 1: Set to zero address
        console.log("--- CASE 1: Setting to zero address ---");
        console.log("--- BEFORE Trigger ---");
        address marketingBefore = token.marketingAddress();
        console.log("Marketing Address Before Trigger: %s", marketingBefore);
        
        console.log("");
        console.log("--- TRIGGER: token.setMarketingAddress(address(0)) ---");
        token.setMarketingAddress(address(0));
        
        console.log("");
        console.log("--- AFTER Trigger ---");
        address marketingAfter = token.marketingAddress();
        console.log("Marketing Address After Trigger: %s", marketingAfter);
        bool zeroAddressSet = (marketingAfter == address(0));
        console.log("Change Occurred: %s", (marketingAfter != marketingBefore) ? "YES" : "NO");
        console.log("Attack Success: %s", zeroAddressSet ? "YES" : "NO");
        console.log("--------------------------------------");
        
        // Case 2: Set to non-payable contract
        console.log("");
        console.log("--- CASE 2: Setting to non-payable contract ---");
        console.log("--- BEFORE Trigger ---");
        marketingBefore = token.marketingAddress();
        console.log("Marketing Address Before Trigger: %s", marketingBefore);
        
        NonPayable nonPayable = new NonPayable();
        console.log("");
        console.log("--- TRIGGER: token.setMarketingAddress(address(nonPayable)) ---");
        token.setMarketingAddress(address(nonPayable));
        
        console.log("");
        console.log("--- AFTER Trigger ---");
        marketingAfter = token.marketingAddress();
        console.log("Marketing Address After Trigger: %s", marketingAfter);
        bool nonPayableSet = (marketingAfter == address(nonPayable));
        console.log("Change Occurred: %s", (marketingAfter != marketingBefore) ? "YES" : "NO");
        console.log("Attack Success: %s", nonPayableSet ? "YES" : "NO");
        console.log("--------------------------------------");
        
        // Final verdict
        if (zeroAddressSet || nonPayableSet) {
            console.log("Vulnerability Exists: Marketing address can be set to invalid addresses");
        } else {
            console.log("Vulnerability not Exist: Marketing address remains valid after operations");
        }
    }
}