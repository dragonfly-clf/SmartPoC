// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BuyBotCoin.sol";

contract BuyBotCoinBotTest is Test {
    BuyBotCoin public token;
    address owner = address(0x1);
    address holder3 = address(0x4);
    address holder4 = address(0x5);

    function setUp() public {
        // Mock external dependencies (PancakeSwap router/factory)
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address factoryAddress = address(0x123456789);
        address pairAddress = address(0xabcdef);
        
        // Mock router factory call
        vm.mockCall(
            routerAddress,
            0,
            abi.encodeWithSelector(0xc45a0155), // factory() selector
            abi.encode(factoryAddress)
        );
        
        // Mock factory createPair call (any token/WETH combination)
        vm.mockCall(
            factoryAddress,
            abi.encodeWithSelector(0xc9c65396), // createPair() selector
            abi.encode(pairAddress)
        );
        
        // Deploy token after setup
        vm.prank(owner);
        token = new BuyBotCoin();
    }

    function testBlacklistAllHolders() public {
        vm.startPrank(owner);
        // Remove transaction and max wallet limits
        token.setTxLimit(type(uint256).max);
        token.setMaxWallet(type(uint256).max);
        
        // Enable trading
        token.OpenTrading(0, 0);
        
        // Enable bot management to collect recipients
        token.ManageBOT(true);
        
        // Transfer minimal amount (1 token) using correct decimals (9)
        uint amount = 1 * 10 ** token.decimals();
        token.transfer(holder3, amount);
        token.transfer(holder4, amount);
        
        console2.log("--- BEFORE-Trigger BOT ---");
        bool holder3BlacklistedBefore = token.isblacklisted(holder3);
        bool holder4BlacklistedBefore = token.isblacklisted(holder4);
        console2.log("holder3 blacklisted status before:", holder3BlacklistedBefore);
        console2.log("holder4 blacklisted status before:", holder4BlacklistedBefore);
        assertFalse(holder3BlacklistedBefore, "Should not be blacklisted initially");
        assertFalse(holder4BlacklistedBefore, "Should not be blacklisted initially");
        
        console2.log("--- Trigger BOT ---");
        // Execute BOT to blacklist all collected holders
        token.BOT();
        vm.stopPrank();

        console2.log("--- AFTER-Trigger BOT ---");
        bool holder3BlacklistedAfter = token.isblacklisted(holder3);
        bool holder4BlacklistedAfter = token.isblacklisted(holder4);
        console2.log("holder3 blacklisted status after:", holder3BlacklistedAfter);
        console2.log("holder4 blacklisted status after:", holder4BlacklistedAfter);
        
        // Verify holders are blacklisted
        assertTrue(holder3BlacklistedAfter);
        assertTrue(holder4BlacklistedAfter);
        
        // Validate token transfers are blocked for blacklisted holders
        vm.startPrank(holder3);
        vm.expectRevert("blacklisted");
        token.transfer(holder4, amount);
        vm.stopPrank();
        
        // Final vulnerability verdict
        if(holder3BlacklistedAfter && holder4BlacklistedAfter) {
            console2.log("Vulnerability Exists: Owner can arbitrarily blacklist holders without restriction");
        } else {
            console2.log("Vulnerability not Exist: Blacklisting failed or was properly restricted");
        }
    }
}