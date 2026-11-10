// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract MockPair {
    // Minimal implementation to satisfy interface
}

contract MockFactory {
    address public pair;

    constructor(address _pair) {
        pair = _pair;
    }

    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockRouter {
    address public factory;
    address public immutable WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    constructor(address _factory) {
        factory = _factory;
    }
}

contract ELFM_Test is Test {
    CoinToken token;
    address owner = address(this);
    address[6] addrs;
    uint256[8] taxValues;

    MockFactory mockFactory;
    MockRouter mockRouter;
    MockPair mockPair;

    function setUp() public {
        // Deploy mock Uniswap ecosystem
        mockPair = new MockPair();
        mockFactory = new MockFactory(address(mockPair));
        mockRouter = new MockRouter(address(mockFactory));

        // Configure token addresses
        addrs = [
            address(0x100), // liquidity wallet
            address(mockRouter), // router address
            address(0x200), // dev wallet
            address(0x300), // marketing wallet
            address(0x400), // charity wallet
            owner // contract owner
        ];
        
        // Initialize with safe tax values
        taxValues = [
            1, 1, 1, 1, // buy taxes: dev, marketing, charity, liquidity (4%)
            1, 1, 1, 1  // sell taxes: dev, marketing, charity, liquidity (4%)
        ];
        
        // Deploy token with mock environment
        token = new CoinToken{value: 0}(
            "TestToken", 
            "TST", 
            1e18, 
            addrs,
            taxValues
        );
    }
    
    function test_OwnerCanSetBuyTaxAbove25Percent() public {
        console2.log("--- BEFORE-Trigger BuyTax ---");
        console2.log("Attempting to set buy tax to 26%");
        
        // Low-level call for first tax change
        console2.log("--- Trigger setBuyTax(10,10,5,1) ---");
        (bool success1, ) = address(token).call(
            abi.encodeWithSignature("setBuyTax(uint256,uint256,uint256,uint256)", 10,10,5,1)
        );
        console2.log("Call status:", success1 ? "SUCCESS" : "REVERT");

        // Second extreme tax change
        console2.log("--- Trigger setBuyTax(100,100,100,100) ---");
        (bool success2, ) = address(token).call(
            abi.encodeWithSignature("setBuyTax(uint256,uint256,uint256,uint256)", 100,100,100,100)
        );
        console2.log("Call status:", success2 ? "SUCCESS" : "REVERT");
        
        console2.log("--- AFTER-Trigger BuyTax ---");
        if (success1 || success2) {
            console2.log("Vulnerability Exists: Buy tax can exceed 25% limit");
        } else {
            console2.log("Vulnerability not Exist: Buy tax cap enforced");
        }
    }
    
    function test_OwnerCanSetSellTaxAbove25Percent() public {
        console2.log("--- BEFORE-Trigger SellTax ---");
        console2.log("Attempting to set sell tax to 26%");
        
        // First tax change
        console2.log("--- Trigger setSellTax(10,10,5,1) ---");
        (bool success1, ) = address(token).call(
            abi.encodeWithSignature("setSellTax(uint256,uint256,uint256,uint256)", 10,10,5,1)
        );
        console2.log("Call status:", success1 ? "SUCCESS" : "REVERT");

        // Second extreme tax change
        console2.log("--- Trigger setSellTax(100,100,100,100) ---");
        (bool success2, ) = address(token).call(
            abi.encodeWithSignature("setSellTax(uint256,uint256,uint256,uint256)", 100,100,100,100)
        );
        console2.log("Call status:", success2 ? "SUCCESS" : "REVERT");
        
        console2.log("--- AFTER-Trigger SellTax ---");
        if (success1 || success2) {
            console2.log("Vulnerability Exists: Sell tax can exceed 25% limit");
        } else {
            console2.log("Vulnerability not Exist: Sell tax cap enforced");
        }
    }
    
    function test_CanSetHighTaxesInConstructor() public {
        console2.log("--- Trigger: Deploy new token with high taxes ---");
        
        // Create new tax values that exceed 25% limit
        uint256[8] memory highTaxes;
        highTaxes[0] = 10;  // buy dev
        highTaxes[1] = 10;  // buy marketing
        highTaxes[2] = 1;   // buy charity
        highTaxes[3] = 5;   // buy liquidity (total: 26%)
        highTaxes[4] = 15;  // sell dev
        highTaxes[5] = 10;  // sell marketing
        highTaxes[6] = 1;   // sell charity
        highTaxes[7] = 5;   // sell liquidity (total: 31%)
        
        // Attempt deployment with try/catch
        try new CoinToken{value: 0}(
            "HighTaxToken",
            "HTX",
            1e18,
            addrs,
            highTaxes
        ) {
            console2.log("--- AFTER-Trigger Constructor Deploy ---");
            console2.log("Vulnerability Exists: Constructor allows taxes >25%");
        } catch {
            console2.log("--- AFTER-Trigger Constructor Revert ---");
            console2.log("Vulnerability not Exist: Constructor reverts excessive taxes");
        }
    }
}