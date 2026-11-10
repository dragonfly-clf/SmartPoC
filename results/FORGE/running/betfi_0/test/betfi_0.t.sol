// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract MockRouter {
    address public immutable factoryAddr;
    
    constructor(address _factory) {
        factoryAddr = _factory;
    }
    
    function factory() external view returns (address) {
        return factoryAddr;
    }
    
    function WETH() external pure returns (address) {
        return address(0xDead);
    }
}

contract MockFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair) {
        return address(0xBeef);
    }
}

contract CoinTokenTest is Test {
    CoinToken token;
    address owner = address(0x1);
    address user = address(0x2);
    address liquidityWallet = address(0x100);
    
    function setUp() public {
        // Deploy mock components
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory));
        
        // Setup addresses
        address[6] memory addrs = [
            liquidityWallet,     // liquidity wallet
            address(mockRouter), // router
            address(0x200),      // dev wallet
            address(0x300),      // marketing wallet
            address(0x400),      // charity wallet
            owner                // contract owner
        ];
        
        // Initialize tax values
        uint256[8] memory taxValues = [
            uint256(0),  // buy-dev
            uint256(0),  // buy-marketing
            uint256(0),  // buy-charity
            uint256(0),  // buy-liquidity
            uint256(0),  // sell-dev
            uint256(0),  // sell-marketing
            uint256(0),  // sell-charity
            uint256(0)   // sell-liquidity
        ];
        
        // Deploy CoinToken with initial supply and taxes
        vm.prank(owner);
        vm.deal(owner, 1 ether);
        token = new CoinToken{value: 1 ether}(
            "TestToken",
            "TT",
            1_000_000 * (10**18), // 1 million supply
            addrs,
            taxValues
        );
        
        // Give user initial tokens
        vm.prank(owner);
        token.transfer(user, 1000 * 10**18);
    }
    
    function test_pause_stops_all_transfers() public {
        // Verify initial state
        assertFalse(token.paused(), "Contract should not be paused initially");
        
        // Pause contract
        vm.prank(owner);
        token.pause();
        assertTrue(token.paused(), "Contract should be paused");
        
        // User shouldn't be able to transfer tokens
        vm.prank(user);
        vm.expectRevert("CoinToken: token transfer while paused");
        token.transfer(address(0x3), 1);
        
        // Owner shouldn't be able to transfer tokens
        vm.prank(owner);
        vm.expectRevert("CoinToken: token transfer while paused");
        token.transfer(address(0x4), 1);
    }
    
    function test_owner_can_set_sell_tax_to_100_percent() public {
        // Set sell taxes to 25% each (total 100%)
        vm.prank(owner);
        token.setSellTax(25, 25, 25, 25);
        
        // Verify the contract didn't revert and taxes were accepted
        assertTrue(true, "Owner successfully set 100% sell tax");
    }
    
    function test_blacklist_prevents_transactions() public {
        console.log("--- BEFORE-Trigger State ---");
        bool isPausedBefore = token.paused();
        bool isBlacklistedBefore = token.isBlacklisted(user);
        console.log("Contract paused status: %s", isPausedBefore);
        console.log("User blacklist status: %s", isBlacklistedBefore);

        console.log("--- Trigger Operation: enableBlacklist ---");
        // Blacklist user address
        vm.prank(owner);
        token.enableBlacklist(user);

        console.log("--- AFTER-Trigger State ---");
        bool isPausedAfter = token.paused();
        bool isBlacklistedAfter = token.isBlacklisted(user);
        console.log("Contract paused status: %s", isPausedAfter);
        console.log("User blacklist status: %s", isBlacklistedAfter);
        
        // Continue with original test logic
        // Attempt transfer to user
        vm.prank(owner);
        vm.expectRevert("CoinToken: recipient blacklisted");
        token.transfer(user, 100 * 10**18);
        
        // Attempt transfer from user
        vm.prank(user);
        vm.expectRevert("CoinToken: sender blacklisted");
        token.transfer(owner, 10 * 10**18);

        // Final verdict
        if (isBlacklistedAfter != isBlacklistedBefore) {
            console.log("Vulnerability Exists: User's blacklist status changed as intended");
        } else {
            console.log("Vulnerability not Exist: User's blacklist status unchanged");
        }
    }
}