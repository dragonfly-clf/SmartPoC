// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/PULIINU.sol";

contract MockRouterRuntime {
    function factory() external pure returns (address) {
        return address(0xc0deF0D105C123F3EE0d8c6E8C895AeD0f000000);
    }

    function WETH() external pure returns (address) {
        return address(0x000000000000000000000000000000000000dEaD);
    }
}

contract MockFactoryRuntime {
    event PairCreated(address tokenA, address tokenB, address pair);

    function createPair(address, address) external returns (address) {
        address pair = 0x1234567890123456789012345678901234567890;
        emit PairCreated(address(0), address(0), pair);
        return pair;
    }
}

contract PULIINUTransactionStopTest is Test {
    PULIINU token;
    address owner = address(0x1);
    address alice = address(0x200);
    address bob = address(0x300);
    uint8 decimals;
    uint256 decimalFactor;
    
    address constant routerAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address constant factoryAddress = address(0xc0deF0D105C123F3EE0d8c6E8C895AeD0f000000);
    address constant pairAddress = address(0x1234567890123456789012345678901234567890);

    function setUp() public {
        // Setup mock router and factory
        bytes memory mockRouterRuntime = type(MockRouterRuntime).runtimeCode;
        bytes memory mockFactoryRuntime = type(MockFactoryRuntime).runtimeCode;
        vm.etch(routerAddress, mockRouterRuntime);
        vm.etch(factoryAddress, mockFactoryRuntime);

        // Deploy contract with ZERO fees
        vm.startPrank(owner);
        token = new PULIINU(
            0,     // deadBlocks
            0,     // buy liquidity fee 
            0,     // buy market fee 
            0,     // sell liquidity fee 
            0,     // sell market fee 
            payable(owner), 
            1000000,  // total supply: 1M tokens
            1000,     // numTokensSellToAddToLiquidity
            10000,    // max wallet tokens
            10000,    // max buy tokens
            10000     // max sell tokens
        );
        vm.stopPrank();

        decimals = token.decimals();
        decimalFactor = 10 ** decimals;

        // Activate trading
        vm.prank(owner);
        token.launch();

        // Fund test account with 500 tokens
        uint256 aliceAmount = 500 * decimalFactor;
        vm.prank(owner);
        token.transfer(alice, aliceAmount);
    }

    function testWalletLimitBlock() public {
        uint256 transferAmount = 100 * decimalFactor;
        
        // Verify normal transfer works (no revert)
        console.log("--- BEFORE-Trigger Transfer ---");
        vm.prank(alice);
        token.transfer(bob, transferAmount);
        console.log("Normal transfer succeeded");

        // Set max wallet to 0 - should block transfers
        console.log("--- Trigger setMaxWallet(0) ---");
        vm.prank(owner);
        token.setMaxWallet(0);

        // Verify transfers are blocked
        console.log("--- AFTER-Trigger Transfer Attempt ---");
        bool blocked = false;
        string memory revertReason = "";

        vm.prank(alice);
        try token.transfer(bob, 1 * decimalFactor) returns (bool) {
            console.log("Transfer completed unexpectedly");
        } catch Error(string memory reason) {
            blocked = true;
            revertReason = reason;
            console.log("Transfer reverted with:", reason);
        } catch (bytes memory) {
            blocked = true;
            console.log("Transfer reverted without message");
        }

        // Vulnerability verification
        if (blocked && keccak256(bytes(revertReason)) == keccak256(bytes("Balance exceeds limit"))) {
            console.log("Vulnerability Exists: Transfer blocked after setting maxWallet=0");
        } else {
            console.log("Vulnerability not Exist: Transfer restriction failed");
        }
    }

    function testSellLimitBlock() public {
        uint256 sellAmount = 10 * decimalFactor;
        
        // Verify selling works (no revert)
        console.log("--- BEFORE-Trigger SellTransfer ---");
        vm.prank(alice);
        token.transfer(pairAddress, sellAmount);
        console.log("Sell transfer succeeded");

        // Set max sell amount to 0 - should block sells
        console.log("--- Trigger setMaxSellAmount(0) ---");
        vm.prank(owner);
        token.setMaxSellAmount(0);

        // Verify sells are blocked
        console.log("--- AFTER-Trigger SellTransfer Attempt ---");
        bool blocked = false;
        string memory revertReason = "";

        vm.prank(alice);
        try token.transfer(pairAddress, 1 * decimalFactor) returns (bool) {
            console.log("Sell transfer completed unexpectedly");
        } catch Error(string memory reason) {
            blocked = true;
            revertReason = reason;
            console.log("Sell transfer reverted with:", reason);
        } catch (bytes memory) {
            blocked = true;
            console.log("Sell transfer reverted without message");
        }

        // Vulnerability verification
        if (blocked && keccak256(bytes(revertReason)) == keccak256(bytes("Sell exceeds limit"))) {
            console.log("Vulnerability Exists: Sell blocked after setting maxSellAmount=0");
        } else {
            console.log("Vulnerability not Exist: Sell restriction failed");
        }
    }
}