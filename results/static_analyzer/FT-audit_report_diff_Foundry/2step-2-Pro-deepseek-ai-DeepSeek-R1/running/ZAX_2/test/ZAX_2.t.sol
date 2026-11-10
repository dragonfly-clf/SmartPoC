// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ZAX.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1);
    }
}

contract MockRouter {
    address factoryAddr;
    address weth;

    constructor(address _factory, address _weth) {
        factoryAddr = _factory;
        weth = _weth;
    }

    function factory() external view returns (address) {
        return factoryAddr;
    }

    function WETH() external view returns (address) {
        return weth;
    }
}

contract ZAXTest is Test {
    ZAX token;
    address owner = vm.addr(1);
    address user1 = vm.addr(2);
    address user2 = vm.addr(3);
    uint256 initialSupply;

    function setUp() public {
        vm.startPrank(owner);

        // Create mock contracts
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory), address(0));
        
        // Initialize token
        token = new ZAX(address(mockRouter));
        initialSupply = token.totalSupply();

        // Configure token settings
        token.setTradingStatus(true, 0, 0, 0, 0, 0);
        token.updateCooldown(true, 1 days); // Cooldown of 1 day
        token.updateMaxTxLimit(initialSupply / 2, initialSupply / 2);
        token.updateMaxWalletlimit(initialSupply);
        
        // Distribute tokens
        token.transfer(user1, initialSupply / 2);
        
        vm.stopPrank();
    }

    function testLastSellBypass() public {
        uint256 transferAmount = 10 * 10**token.decimals(); // 10 tokens

        console.log("--- BEFORE-Trigger ---");
        console.log("User1 balance:", token.balanceOf(user1));
        console.log("User2 balance:", token.balanceOf(user2));
        console.log("Current block timestamp:", block.timestamp);
        console.log("Expected behavior: Transfer should be blocked by cooldown");

        console.log("--- Trigger Transfer ---");
        console.log("Attempting transfer (should fail without cooldown)...");
        
        bool success;
        vm.prank(user1);
        try token.transfer(user2, transferAmount) {
            success = true;
        } catch (bytes memory) {
            success = false;
        }

        console.log("--- AFTER-Trigger ---");
        console.log("Transfer status:", success ? "SUCCEEDED" : "REVERTED");
        console.log("User1 balance:", token.balanceOf(user1));
        console.log("User2 balance:", token.balanceOf(user2));
        
        if (success) {
            console.log("VERDICT: Transfer bypassed cooldown protection");
            console.log("Vulnerability Exists: lastSell cooldwn bypassed");
        } else {
            console.log("VERDICT: Cooldown protection blocked transfer as expected");
            console.log("Vulnerability not Exist: lastSell cooldown enforcement works");
        }
    }
}