// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/RewardToken.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0xBEEFBABE);
    }
}

contract MockUniswapV2Router {
    address public immutable factory;
    address public immutable WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    constructor() {
        factory = address(new MockUniswapV2Factory());
    }
}

contract RewardTokenAuditTest is Test {
    RewardToken public token;
    address public owner;
    address constant REWARD_TOKEN = address(0x123);
    address constant MARKETING_WALLET = address(0x456);

    // Add receive function to accept 0 ETH payments
    receive() external payable {}

    function setUp() public {
        owner = address(this);
        
        uint256 supply = 1e9 * 1e9;  // 1 billion tokens with 9 decimals
        uint256 minTokens = 1e6;     // Minimum token balance for dividends
        uint256 initialRewardsFee = 1;  // Initial rewards fee (1%)
        
        uint256[] memory fees = new uint256[](3);
        fees[0] = 1;  // liquidityFee
        fees[1] = 1;  // marketingFee
        fees[2] = 0;  // extraSellFee

        // Deploy mock router
        MockUniswapV2Router router = new MockUniswapV2Router();
        address routerAddress = address(router);

        // Deploy token with mocks
        token = new RewardToken{value: 0}(
            "TestToken",
            "TEST",
            supply,
            9,                     // decimals
            REWARD_TOKEN,          // rewardToken_
            initialRewardsFee,     // rewardsFee_
            minTokens,             // minTokens_
            fees,                  // fees_
            MARKETING_WALLET,      // marketing wallet
            routerAddress,         // router
            owner                  // owner
        );
    }

    // Test: Owner can set rewards fee arbitrarily
    function test_rewards_fee_setting() public {
        uint256 newFee = 100; // Set to 100%
        
        console.log("--- BEFORE-Trigger rewards_fee_setting ---");
        uint256 beforeFee = token.rewardsFee();
        console.log("Initial rewards fee: ", beforeFee);

        console.log("--- Trigger: call setTokenRewardsFee(100) ---");
        token.setTokenRewardsFee(newFee);

        console.log("--- AFTER-Trigger rewards_fee_setting ---");
        uint256 afterFee = token.rewardsFee();
        console.log("Final rewards fee: ", afterFee);
        
        assertEq(afterFee, newFee, "Rewards fee not updated to 100%");
        
        // Final vulnerability verdict
        if (afterFee == newFee) {
            console.log("Vulnerability Exists: Rewards fee modified by owner");
        } else {
            console.log("Vulnerability not Exist: Rewards fee unchanged");
        }
    }

    // Test: Owner can set liquidity fee arbitrarily
    function test_liquidity_fee_setting() public {
        uint256 newFee = 100; // Set to 100%
        
        console.log("--- BEFORE-Trigger liquidity_fee_setting ---");
        uint256 beforeFee = token.liquidityFee();
        console.log("Initial liquidity fee: ", beforeFee);

        console.log("--- Trigger: call setLiquiditFee(100) ---");
        token.setLiquiditFee(newFee);

        console.log("--- AFTER-Trigger liquidity_fee_setting ---");
        uint256 afterFee = token.liquidityFee();
        console.log("Final liquidity fee: ", afterFee);
        
        assertEq(afterFee, newFee, "Liquidity fee not updated to 100%");
        
        // Final vulnerability verdict
        if (afterFee == newFee) {
            console.log("Vulnerability Exists: Liquidity fee modified by owner");
        } else {
            console.log("Vulnerability not Exist: Liquidity fee unchanged");
        }
    }

    // Test: Owner can set marketing fee arbitrarily
    function test_marketing_fee_setting() public {
        uint256 newFee = 100; // Set to 100%
        
        console.log("--- BEFORE-Trigger marketing_fee_setting ---");
        uint256 beforeFee = token.marketingFee();
        console.log("Initial marketing fee: ", beforeFee);

        console.log("--- Trigger: call setMarketingFee(100) ---");
        token.setMarketingFee(newFee);

        console.log("--- AFTER-Trigger marketing_fee_setting ---");
        uint256 afterFee = token.marketingFee();
        console.log("Final marketing fee: ", afterFee);
        
        assertEq(afterFee, newFee, "Marketing fee not updated to 100%");
        
        // Final vulnerability verdict
        if (afterFee == newFee) {
            console.log("Vulnerability Exists: Marketing fee modified by owner");
        } else {
            console.log("Vulnerability not Exist: Marketing fee unchanged");
        }
    }

    // Test: Total fees sum updates correctly
    function test_total_fees_update() public {
        // Part 1: Set all fees to 1%
        console.log("--- BEFORE-Trigger setFees(1) ---");
        uint256 rewardsBefore = token.rewardsFee();
        uint256 liquidityBefore = token.liquidityFee();
        uint256 marketingBefore = token.marketingFee();
        uint256 totalFeesBefore = token.totalFees();
        
        string memory beforeFeesMsg = string.concat(
            "Initial fees - Rewards: ", vm.toString(rewardsBefore),
            ", Liquidity: ", vm.toString(liquidityBefore),
            ", Marketing: ", vm.toString(marketingBefore),
            ", Total: ", vm.toString(totalFeesBefore)
        );
        console.log(beforeFeesMsg);

        console.log("--- Trigger: setting all fees to 1% ---");
        token.setTokenRewardsFee(1);
        token.setLiquiditFee(1);
        token.setMarketingFee(1);

        console.log("--- AFTER-Trigger setFees(1) ---");
        uint256 rewardsAfter1 = token.rewardsFee();
        uint256 liquidityAfter1 = token.liquidityFee();
        uint256 marketingAfter1 = token.marketingFee();
        uint256 totalFeesAfter1 = token.totalFees();
        
        string memory afterFeesMsg1 = string.concat(
            "After setting 1% fees - Rewards: ", vm.toString(rewardsAfter1),
            ", Liquidity: ", vm.toString(liquidityAfter1),
            ", Marketing: ", vm.toString(marketingAfter1),
            ", Total: ", vm.toString(totalFeesAfter1)
        );
        console.log(afterFeesMsg1);
        
        assertEq(totalFeesAfter1, 3, "Fees sum mismatch after 1% settings: expected 3");
        
        // Part 2: Increase rewards fee to 50%
        console.log("--- BEFORE-Trigger reward_fee_increase ---");
        console.log("Current rewards fee: ", token.rewardsFee(), "Total fees: ", token.totalFees());

        console.log("--- Trigger: setTokenRewardsFee(50) ---");
        token.setTokenRewardsFee(50);

        console.log("--- AFTER-Trigger reward_fee_increase ---");
        uint256 rewardsAfter2 = token.rewardsFee();
        uint256 totalFeesAfter2 = token.totalFees();
        console.log("After increase - Rewards fee: ", rewardsAfter2, "Total fees: ", totalFeesAfter2);
        
        assertEq(totalFeesAfter2, 52, "Fees sum mismatch after increase: expected 52");
        
        // Final vulnerability verdict
        if (rewardsAfter2 == 50 && totalFeesAfter2 == 52) {
            console.log("Vulnerability Exists: Total fee calculation confirms owner can modify fees");
        } else if (totalFeesAfter2 != rewardsAfter2 + liquidityAfter1 + marketingAfter1) {
            console.log("Vulnerability not Exist: Total fees unchanged or miscalculated");
        }
    }

    // Test: Owner can blacklist addresses
    function test_blacklist_function() public {
        address testAddress = makeAddr("testUser");
        
        // Blacklist operation
        console.log("--- BEFORE-Trigger blacklist ---");
        bool beforeBlacklistStatus = token.isBlacklisted(testAddress);
        console.log("Blacklist status before: ", beforeBlacklistStatus);

        console.log("--- Trigger: blacklistAddress(true) ---");
        token.blacklistAddress(testAddress, true);

        console.log("--- AFTER-Trigger blacklist ---");
        bool afterBlacklistStatus = token.isBlacklisted(testAddress);
        console.log("Blacklist status after: ", afterBlacklistStatus);
        
        assertTrue(afterBlacklistStatus, "Address should be blacklisted");
        
        // Unblacklist operation
        console.log("--- BEFORE-Trigger unblacklist ---");
        console.log("Current blacklist status: ", afterBlacklistStatus);

        console.log("--- Trigger: blacklistAddress(false) ---");
        token.blacklistAddress(testAddress, false);

        console.log("--- AFTER-Trigger unblacklist ---");
        bool afterUnblacklistStatus = token.isBlacklisted(testAddress);
        console.log("Final blacklist status: ", afterUnblacklistStatus);
        
        assertFalse(afterUnblacklistStatus, "Address should be un-blacklisted");
        
        // Final vulnerability verdict
        if (!afterUnblacklistStatus && afterBlacklistStatus) {
            console.log("Vulnerability Exists: Blacklist status changed by owner");
        } else {
            console.log("Vulnerability not Exist: Blacklist status not modified");
        }
    }
}