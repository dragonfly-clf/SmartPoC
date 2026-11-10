// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract MockUniswapV2Router02 {
    address public factory;
    constructor(address _factory) {
        factory = _factory;
    }
    function WETH() external pure returns (address) {
        return address(0xdead);
    }
}

contract MockUniswapV2Factory {
    function createPair(address, address) external returns (address) {
        return address(0x123);
    }
}

contract TaxExceedTest is Test {
    CoinToken token;
    address owner = makeAddr("owner");
    address marketingWallet = makeAddr("marketing");
    address devWallet = makeAddr("dev");
    address charityWallet = makeAddr("charity");
    uint256 constant MAX_ALLOWED_TAX = 25; // 25% is maximum allowed
    uint256 constant EXCESSIVE_TAX = 26;   // 26% tax to test limit exceed

    function setUp() public {
        uint256 initialSupply = 10_000_000 ether;
        vm.deal(owner, 10 ether);
        vm.startPrank(owner);
        
        MockUniswapV2Factory factory = new MockUniswapV2Factory();
        MockUniswapV2Router02 router = new MockUniswapV2Router02(address(factory));
        
        // Initialize wallets for tax addresses
        address[6] memory wallets = [
            owner,              // liquidity wallet
            address(router),    // router address
            devWallet,          // dev wallet
            marketingWallet,    // marketing wallet
            charityWallet,      // charity wallet
            owner               // owner
        ];
        
        // Explicitly type taxes array as uint256[]
        uint256[8] memory taxes = _createTaxArray();
        
        token = new CoinToken{value: 0}(
            "TestToken",
            "TT",
            initialSupply,
            wallets,
            taxes
        );
        
        vm.stopPrank();
    }

    // Helper to create properly typed tax array
    function _createTaxArray() internal pure returns (uint256[8] memory) {
        return [uint256(0), 0, 0, 0, 0, 0, 0, 0];
    }

    // Test buy tax limit vulnerability
    function testSetExcessiveBuyTax() public {
        console.log("--- BEFORE-Trigger ---");
        console.log(
            string(abi.encodePacked(
                "Attempting to set buyDevTax to: ", 
                vm.toString(EXCESSIVE_TAX), 
                "% (allowed max: ", 
                vm.toString(MAX_ALLOWED_TAX),
                "%)"
            ))
        );
        
        console.log("--- Trigger Attack: setBuyTax ---");
        bool noRevert = false;
        string memory revertReason;
        vm.startPrank(owner);
        try token.setBuyTax(EXCESSIVE_TAX, 0, 0, 0) {
            noRevert = true;
        } catch Error(string memory reason) {
            revertReason = reason;
        } catch {
            revertReason = "Panic without revert string";
        }
        vm.stopPrank();

        console.log("--- AFTER-Trigger ---");
        if (noRevert) {
            console.log("Transaction executed without revert");
            console.log("Vulnerability Exists: Tax cap validation missing for buy transactions");
        } else {
            console.log(string(abi.encodePacked("Transaction reverted: ", revertReason)));
            console.log("Vulnerability not Exist: Reverted when exceeding tax limit");
        }
        
        // Final verdict logging
        console.log(noRevert ? 
            "Vulnerability Exists: Owner can bypass tax limits" :
            "Vulnerability not Exist: Tax limit validation works"
        );
    }

    // Test sell tax limit vulnerability
    function testSetExcessiveSellTax() public {
        console.log("--- BEFORE-Trigger ---");
        console.log(
            string(abi.encodePacked(
                "Attempting to set sellCharityTax to: ", 
                vm.toString(EXCESSIVE_TAX), 
                "% (allowed max: ", 
                vm.toString(MAX_ALLOWED_TAX),
                "%)"
            ))
        );
        
        console.log("--- Trigger Attack: setSellTax ---");
        bool noRevert = false;
        string memory revertReason;
        vm.startPrank(owner);
        try token.setSellTax(0, 0, 0, EXCESSIVE_TAX) {
            noRevert = true;
        } catch Error(string memory reason) {
            revertReason = reason;
        } catch {
            revertReason = "Panic without revert string";
        }
        vm.stopPrank();

        console.log("--- AFTER-Trigger ---");
        if (noRevert) {
            console.log("Transaction executed without revert");
            console.log("Vulnerability Exists: Tax cap validation missing for sell transactions");
        } else {
            console.log(string(abi.encodePacked("Transaction reverted: ", revertReason)));
            console.log("Vulnerability not Exist: Reverted when exceeding tax limit");
        }
        
        // Final verdict logging
        console.log(noRevert ? 
            "Vulnerability Exists: Owner can bypass tax limits" :
            "Vulnerability not Exist: Tax limit validation works"
        );
    }
}