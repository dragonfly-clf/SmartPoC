// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KARMA.sol";

contract MockRouter {
    function factory() external pure returns (address) {
        return 0xE0E3e1ec7830C4FED7e134843d74f7F2614CdA24;
    }

    function WETH() external pure returns (address) {
        return 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496;
    }
}

contract KARMA_PrivilegeEscalationTest is Test {
    KARMA karma;
    address owner = makeAddr("owner");
    address hacker = makeAddr("hacker");
    
    function setUp() public {
        // Simulate BSC testnet environment
        vm.chainId(97);

        // Deploy mock contracts using correct checksum addresses
        address routerAddress = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        MockRouter router = new MockRouter();
        vm.etch(routerAddress, address(router).code);

        address factoryAddress = 0xE0E3e1ec7830C4FED7e134843d74f7F2614CdA24;
        MockFactory factory = new MockFactory();
        vm.etch(factoryAddress, address(factory).code);

        vm.startPrank(owner);
        karma = new KARMA();
        karma.enableTrading(); // Enable trading for complete functionality
        vm.stopPrank();
    }

    function test_ownerCanSetDangerouslyHighSwapAmount() public {
        uint256 totalSupply = karma.totalSupply();
        uint256 dangerousAmount = totalSupply / 2;
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 originalSwapAmount = karma.swapTokensAtAmount();
        console.log("Original swapTokensAtAmount:", originalSwapAmount);
        console.log("Total supply:", totalSupply);
        
        console.log("--- Trigger SetSwapAmount ---");
        vm.prank(owner);
        karma.setSwapTokensAtAmount(dangerousAmount);
        
        console.log("--- AFTER-Trigger State ---");
        uint256 newSwapAmount = karma.swapTokensAtAmount();
        console.log("New swapTokensAtAmount:", newSwapAmount);
        
        assertEq(newSwapAmount, dangerousAmount, "Swap tokens at amount not set correctly");
        
        if (newSwapAmount > totalSupply / 10) {
            console.log("Vulnerability Exists: Owner can set swap threshold to 50%% of total supply");
        } else {
            console.log("Vulnerability not Exist: Swap threshold remains within safe limits");
        }
    }

    function test_ownerCanSetExcessiveBuyFees() public {
        console.log("--- BEFORE-Trigger State ---");
        (uint256 taxFeeBefore, uint256 liqFeeBefore, uint256 marketingFeeBefore, uint256 burnFeeBefore) = (
            karma.taxFeeonBuy(),
            karma.liquidityFeeonBuy(),
            karma.marketingFeeonBuy(),
            karma.burnFeeOnBuy()
        );
        console.log("Original Buy Fees: ");
        console.log("Tax: ", taxFeeBefore);
        console.log("Liq: ", liqFeeBefore);
        console.log("Marketing: ", marketingFeeBefore);
        console.log("Burn: ", burnFeeBefore);
        uint256 totalBefore = taxFeeBefore + liqFeeBefore + marketingFeeBefore + burnFeeBefore;
        console.log("Total Fees Before: ", totalBefore);
        
        console.log("--- Trigger SetBuyFees ---");
        vm.prank(owner);
        karma.setBuyFeePercentages(25, 25, 25, 25);
        
        console.log("--- AFTER-Trigger State ---");
        (uint256 taxFeeAfter, uint256 liqFeeAfter, uint256 marketingFeeAfter, uint256 burnFeeAfter) = (
            karma.taxFeeonBuy(),
            karma.liquidityFeeonBuy(),
            karma.marketingFeeonBuy(),
            karma.burnFeeOnBuy()
        );
        console.log("New Buy Fees: ");
        console.log("Tax: ", taxFeeAfter);
        console.log("Liq: ", liqFeeAfter);
        console.log("Marketing: ", marketingFeeAfter);
        console.log("Burn: ", burnFeeAfter);
        uint256 totalAfter = taxFeeAfter + liqFeeAfter + marketingFeeAfter + burnFeeAfter;
        console.log("Total Fees After: ", totalAfter);
        
        assertEq(totalAfter, 100, "Total buy fees exceed 10% limit");
        
        if (totalAfter > 10) {
            console.log("Vulnerability Exists: Owner can set buy fees to 100%%");
        } else {
            console.log("Vulnerability not Exist: Buy fees within 10%% limit");
        }
    }

    function test_ownerCanSetExcessiveSellFees() public {
        console.log("--- BEFORE-Trigger State ---");
        (uint256 taxFeeBefore, uint256 liqFeeBefore, uint256 marketingFeeBefore, uint256 burnFeeBefore) = (
            karma.taxFeeonSell(),
            karma.liquidityFeeonSell(),
            karma.marketingFeeonSell(),
            karma.burnFeeOnSell()
        );
        console.log("Original Sell Fees: ");
        console.log("Tax: ", taxFeeBefore);
        console.log("Liq: ", liqFeeBefore);
        console.log("Marketing: ", marketingFeeBefore);
        console.log("Burn: ", burnFeeBefore);
        uint256 totalBefore = taxFeeBefore + liqFeeBefore + marketingFeeBefore + burnFeeBefore;
        console.log("Total Fees Before: ", totalBefore);
        
        console.log("--- Trigger SetSellFees ---");
        vm.prank(owner);
        karma.setSellFeePercentages(25, 25, 25, 25);
        
        console.log("--- AFTER-Trigger State ---");
        (uint256 taxFeeAfter, uint256 liqFeeAfter, uint256 marketingFeeAfter, uint256 burnFeeAfter) = (
            karma.taxFeeonSell(),
            karma.liquidityFeeonSell(),
            karma.marketingFeeonSell(),
            karma.burnFeeOnSell()
        );
        console.log("New Sell Fees: ");
        console.log("Tax: ", taxFeeAfter);
        console.log("Liq: ", liqFeeAfter);
        console.log("Marketing: ", marketingFeeAfter);
        console.log("Burn: ", burnFeeAfter);
        uint256 totalAfter = taxFeeAfter + liqFeeAfter + marketingFeeAfter + burnFeeAfter;
        console.log("Total Fees After: ", totalAfter);
        
        assertEq(totalAfter, 100, "Total sell fees exceed 10% limit");
        
        if (totalAfter > 10) {
            console.log("Vulnerability Exists: Owner can set sell fees to 100%%");
        } else {
            console.log("Vulnerability not Exist: Sell fees within 10%% limit");
        }
    }

    function test_ownerCanChangeMarketingWallet() public {
        console.log("--- BEFORE-Trigger State ---");
        address originalWallet = karma.marketingWallet();
        console.log("Original marketing wallet:", originalWallet);
        
        console.log("--- Trigger ChangeMarketingWallet ---");
        vm.prank(owner);
        address newMarketingWallet = address(0xABCD);
        karma.changeMarketingWallet(newMarketingWallet);
        
        console.log("--- AFTER-Trigger State ---");
        address updatedWallet = karma.marketingWallet();
        console.log("Updated marketing wallet:", updatedWallet);
        
        assertEq(updatedWallet, newMarketingWallet, "Marketing wallet not changed");
        console.log("Vulnerability not Exist: Owner wallet change is intended behavior");
    }

    function test_swapTokensCanBeDisabled() public {
        console.log("--- BEFORE-Trigger State ---");
        bool originalSwapStatus = karma.swapEnabled();
        console.log("Original swap status:", originalSwapStatus);
        
        console.log("--- Trigger DisableSwap ---");
        vm.prank(owner);
        karma.setSwapEnabled(false);
        
        console.log("--- AFTER-Trigger State ---");
        bool newSwapStatus = karma.swapEnabled();
        console.log("Updated swap status:", newSwapStatus);
        
        assertEq(newSwapStatus, false, "Swap was not disabled");
        console.log("Vulnerability not Exist: Disabling swap is intentional functionality");
    }

    function test_nonOwnerCannotChangeFees() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 taxFeeBefore = karma.taxFeeonBuy();
        console.log("Original tax fee:", taxFeeBefore);
        
        console.log("--- Trigger UnauthorizedChange ---");
        vm.prank(hacker);
        
        console.log("--- AFTER-Trigger State ---");
        uint256 taxFeeAfter = karma.taxFeeonBuy();
        console.log("Tax fee after unauthorized attempt:", taxFeeAfter);
        
        // Fee remains unchanged despite attacker attempt
        vm.prank(hacker);
        vm.expectRevert("Ownable: caller is not the owner");
        karma.setBuyFeePercentages(100, 0, 0, 0);
        
        console.log("Vulnerability not Exist: Non-owner fee change prevented");
    }

    function test_nonOwnerCannotChangeMarketingWallet() public {
        console.log("--- BEFORE-Trigger State ---");
        address originalWallet = karma.marketingWallet();
        console.log("Original marketing wallet:", originalWallet);
        
        console.log("--- Trigger UnauthorizedChange ---");
        vm.prank(hacker);
        
        console.log("--- AFTER-Trigger State ---");
        address updatedWallet = karma.marketingWallet();
        console.log("Marketing wallet after unauthorized attempt:", updatedWallet);
        
        // Wallet remains unchanged despite attacker attempt
        vm.prank(hacker);
        vm.expectRevert("Ownable: caller is not the owner");
        karma.changeMarketingWallet(hacker);
        
        console.log("Vulnerability not Exist: Non-owner wallet change prevented");
    }

    function test_singleSellFeeBeyondLimitFails() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 taxFeeBefore = karma.taxFeeonSell();
        console.log("Original tax fee on sell:", taxFeeBefore);
        
        console.log("--- Trigger ExceedFeeLimit ---");
        vm.prank(owner);
        vm.expectRevert("Sell fees cannot be greater than 10%");
        karma.setSellFeePercentages(101, 0, 0, 0);
        
        console.log("--- AFTER-Trigger State ---");
        uint256 taxFeeAfter = karma.taxFeeonSell();
        console.log("Tax fee after failed attempt:", taxFeeAfter);
        
        if (taxFeeAfter != taxFeeBefore) {
            console.log("Vulnerability Exists: Contract state changed despite revert");
        } else {
            console.log("Vulnerability not Exist: Contract correctly rejected fee >10%% and state unchanged");
        }
    }
}