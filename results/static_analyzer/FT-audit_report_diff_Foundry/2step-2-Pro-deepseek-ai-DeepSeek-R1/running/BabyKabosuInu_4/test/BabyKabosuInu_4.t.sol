// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BabyKabosuInu.sol";

contract MockWETH {
    function deposit() external payable {}
    function transfer(address, uint256) external pure returns (bool) {
        return true;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract BabyKabosuInuFeeTest is Test {
    BabyKabosuInu token;
    address owner = address(0x1);
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    // Helper functions to get total fees
    function getTotalBuyFees() public view returns (uint256) {
        return token._ecosystemFee() +
               token._marketingFee() +
               token._rewardFee() +
               token._liquidityFee() +
               token._taxFee();
    }
    
    function getTotalSellFees() public view returns (uint256) {
        return token._SellecosystemFee() +
               token._SellmarketingFee() +
               token._SellrewardFee() +
               token._SelllLiquidityFee() +
               token._SelltaxFee();
    }

    function setUp() public {
        // Deploy mock contracts
        MockWETH mockWETH = new MockWETH();
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory), address(mockWETH));
        
        // Replace hardcoded router address with mock
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);

        vm.startPrank(owner);
        token = new BabyKabosuInu();
        token.setTrading(true);
        vm.stopPrank();
    }

    function test_setBuyFeeAboveMax() public {
        console.log("\n======= TEST SETBUYFEE =======");
        
        // Pre-trigger: Get initial fees
        console.log("--- BEFORE-Trigger Fee State ---");
        uint256 totalBuyBefore = getTotalBuyFees();
        console.log("Initial total buy fee:", totalBuyBefore);
        console.log("Fee breakdown (eco, market, reward, liq, tax): [%d, %d, %d, %d, %d]",
            token._ecosystemFee(),
            token._marketingFee(),
            token._rewardFee(),
            token._liquidityFee(),
            token._taxFee()
        );
        
        // Trigger: Attempt to set illegal fee values
        console.log("--- Trigger: setBuyFee(6,6,6,6,2) ---");
        vm.startPrank(owner);
        token.setBuyFee(6, 6, 6, 6, 2);
        vm.stopPrank();
        
        // Post-trigger: Check updated fees
        console.log("--- AFTER-Trigger Fee State ---");
        uint256 totalBuyAfter = getTotalBuyFees();
        console.log("Updated total buy fee:", totalBuyAfter);
        console.log("Fee breakdown (eco, market, reward, liq, tax): [%d, %d, %d, %d, %d]",
            token._ecosystemFee(),
            token._marketingFee(),
            token._rewardFee(),
            token._liquidityFee(),
            token._taxFee()
        );
        
        // Verification
        if (totalBuyAfter > 25) {
            console.log("Vulnerability Exists: Total buy fees set above 25%% cap");
        } else {
            console.log("Vulnerability not Exist: Buy fee cap enforcement active");
        }
    }

    function test_setSellFeeAboveMax() public {
        console.log("\n======= TEST SETSELLFEE =======");
        
        // Pre-trigger: Get initial fees
        console.log("--- BEFORE-Trigger Fee State ---");
        uint256 totalSellBefore = getTotalSellFees();
        console.log("Initial total sell fee:", totalSellBefore);
        console.log("Fee breakdown (eco, market, reward, liq, tax): [%d, %d, %d, %d, %d]",
            token._SellecosystemFee(),
            token._SellmarketingFee(),
            token._SellrewardFee(),
            token._SelllLiquidityFee(),
            token._SelltaxFee()
        );
        
        // Trigger: Attempt to set illegal fee values
        console.log("--- Trigger: setSellFee(6,6,6,6,2) ---");
        vm.startPrank(owner);
        token.setSellFee(6, 6, 6, 6, 2);
        vm.stopPrank();
        
        // Post-trigger: Check updated fees
        console.log("--- AFTER-Trigger Fee State ---");
        uint256 totalSellAfter = getTotalSellFees();
        console.log("Updated total sell fee:", totalSellAfter);
        console.log("Fee breakdown (eco, market, reward, liq, tax): [%d, %d, %d, %d, %d]",
            token._SellecosystemFee(),
            token._SellmarketingFee(),
            token._SellrewardFee(),
            token._SelllLiquidityFee(),
            token._SelltaxFee()
        );
        
        // Verification
        if (totalSellAfter > 25) {
            console.log("Vulnerability Exists: Total sell fees set above 25%% cap");
        } else {
            console.log("Vulnerability not Exist: Sell fee cap enforcement active");
        }
    }
}