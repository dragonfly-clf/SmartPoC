// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Contract.sol";

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0xABCD);
    }

    function WETH() external pure returns (address) {
        return address(0x111);
    }

    // Minimal implementation to satisfy interface requirements
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint, uint, uint) {
        return (0, 0, 0);
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234567890123456789012345678901234567890);
    }
}

contract ContractAuditTest is Test {
    Contract token;
    address owner = address(0x100);
    address user1 = address(0x200);
    address user2 = address(0x300);
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    function setUp() public {
        // Deploy necessary mocks
        MockRouter mockRouter = new MockRouter();
        MockFactory mockFactory = new MockFactory();
        
        // Capture runtime bytecode
        bytes memory routerCode = address(mockRouter).code;
        bytes memory factoryCode = address(mockFactory).code;
        
        // Mock Pancakeswap router and factory
        vm.etch(PANCAKE_ROUTER, routerCode);
        vm.etch(address(0xABCD), factoryCode);
        
        // Deploy token
        vm.startPrank(owner);
        token = new Contract(
            "TestToken", 
            "TST", 
            1_000_000,
            18,
            payable(owner),
            payable(0),
            0
        );
        vm.stopPrank();
        
        // Fund test users
        vm.prank(owner);
        token.transfer(user1, 10_000 ether);
        vm.prank(owner);
        token.transfer(user2, 10_000 ether);
    }

    function test_owner_can_blacklist_users() public {
        // Pre-trigger state
        bool isBlacklistedPre = token._isBlacklisted(user1);
        bool tradeOpenPre = token.TradeOpen();
        console2.log("--- BEFORE-Trigger ---");
        console2.log("isBlacklisted(user1):", isBlacklistedPre);
        console2.log("TradeOpen:", tradeOpenPre);
        
        console2.log("--- Trigger: Admin blacklist & open trade ---");
        vm.startPrank(owner);
        token.Launch_Settings_01__Blacklist_Bots(user1, true); // True = add to blacklist
        token.Launch_Settings_03__OpenTrade();
        vm.stopPrank();
        
        // Post-trigger state
        bool isBlacklistedPost = token._isBlacklisted(user1);
        bool tradeOpenPost = token.TradeOpen();
        console2.log("--- AFTER-Trigger ---");
        console2.log("isBlacklisted(user1):", isBlacklistedPost);
        console2.log("TradeOpen:", tradeOpenPost);
        
        // Verify exploit: Transfer fails for blacklisted user
        vm.startPrank(user1);
        vm.expectRevert();
        token.transfer(user2, 100 ether);
        vm.stopPrank();
        
        // Differential verdict
        if (isBlacklistedPost && !isBlacklistedPre) {
            console2.log("Vulnerability Exists: Owner can blacklist users arbitrarily");
        } else {
            console2.log("Vulnerability not Exist: Blacklist state unchanged");
        }
    }

    function test_owner_can_sell_before_launch() public {
        // Pre-trigger state
        bool tradeOpenPre = token.TradeOpen();
        console2.log("--- BEFORE-Trigger ---");
        console2.log("TradeOpen:", tradeOpenPre);
        
        console2.log("--- Trigger: Remove from blacklist ---");
        vm.prank(owner);
        token.Launch_Settings_01__Blacklist_Bots(user1, false); // False = remove
        
        // Verify users still can't transfer before launch
        vm.startPrank(user1);
        vm.expectRevert();
        token.transfer(user2, 100 ether);
        vm.stopPrank();
        
        // Pre-transfer state
        uint256 ownerBalancePre = token.balanceOf(owner);
        console2.log("Owner balance pre-transfer:", ownerBalancePre);
        
        console2.log("--- Trigger: Owner transfer ---");
        vm.prank(owner);
        token.transfer(address(0xdead), 100_000 ether);
        
        // Post-trigger state
        uint256 ownerBalancePost = token.balanceOf(owner);
        bool tradeOpenPost = token.TradeOpen();
        console2.log("--- AFTER-Trigger ---");
        console2.log("Owner balance post-transfer:", ownerBalancePost);
        console2.log("TradeOpen:", tradeOpenPost);
        console2.log("Amount transferred:", ownerBalancePre - ownerBalancePost);
        
        // Vulnerability verdict
        if ((ownerBalancePre - ownerBalancePost == 100_000 ether) && !tradeOpenPost) {
            console2.log("Vulnerability Exists: Owner sold tokens before launch");
        } else {
            console2.log("Vulnerability not Exist: Either tokens not transferred or trade opened unexpectedly");
        }
    }

    function test_owner_can_set_limits_within_bounds() public {
        uint256 minLimit = 1_000; // 0.1% of 1,000,000 supply
        
        console2.log("--- BEFORE-Trigger ---");
        console2.log("Note: max_Tran/max_Hold not accessible via getters");
        
        vm.startPrank(owner);
        console2.log("--- Trigger: Set within limits ---");
        token.Contract_SetUp_03__Wallet_Limits(minLimit, minLimit);
        
        console2.log("--- AFTER-Trigger (valid) ---");
        console2.log("Set within limits completed without reverting");
        
        console2.log("--- Trigger: Try below min limits ---");
        vm.expectRevert(bytes("E04"));
        token.Contract_SetUp_03__Wallet_Limits(minLimit - 1, minLimit);
        
        vm.expectRevert(bytes("E05"));
        token.Contract_SetUp_03__Wallet_Limits(minLimit, minLimit - 1);
        vm.stopPrank();
        
        console2.log("--- AFTER-Trigger (reverts) ---");
        console2.log("Set below min limits reverted as expected");
        
        console2.log("Vulnerability not Exist: Limits enforcement works correctly");
    }

    function test_trading_restrictions() public {
        // Pre-trigger state
        bool tradeOpenPre = token.TradeOpen();
        console2.log("--- BEFORE-Trigger ---");
        console2.log("TradeOpen:", tradeOpenPre);
        
        console2.log("--- Trigger: Open trade ---");
        vm.prank(owner);
        token.Launch_Settings_03__OpenTrade();
        
        // Post-trigger state
        bool tradeOpenPost = token.TradeOpen();
        console2.log("--- AFTER-Trigger ---");
        console2.log("TradeOpen:", tradeOpenPost);
        
        // Transfer validation
        uint256 user1BalancePre = token.balanceOf(user1);
        uint256 user2BalancePre = token.balanceOf(user2);
        console2.log("User1 balance pre-transfer:", user1BalancePre);
        console2.log("User2 balance pre-transfer:", user2BalancePre);
        
        vm.prank(user1);
        token.transfer(user2, 100 ether);
        
        uint256 user1BalancePost = token.balanceOf(user1);
        uint256 user2BalancePost = token.balanceOf(user2);
        console2.log("User1 balance post-transfer:", user1BalancePost);
        console2.log("User2 balance post-transfer:", user2BalancePost);
        
        uint256 amountConserved = (user1BalancePre + user2BalancePre) - 
                                 (user1BalancePost + user2BalancePost);
        console2.log("Total tokens conserved:", amountConserved);
        
        // Vulnerability verdict
        if (tradeOpenPost && !tradeOpenPre && amountConserved == 0) {
            console2.log("Vulnerability not Exist: Trading opened successfully");
        } else {
            console2.log("Vulnerability Exists: Trade status unchanged or fees applied unexpectedly");
        }
    }
}