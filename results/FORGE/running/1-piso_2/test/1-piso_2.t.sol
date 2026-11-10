// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PISO.sol";

contract MockWETH {
    // Mock WETH contract
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0x789); // Mock pair address
    }
}

contract MockRouter {
    address public factory;
    address public immutable WETH;
    
    constructor() {
        factory = address(new MockFactory());
        WETH = address(new MockWETH());
    }
}

contract PISOFeeTest is Test {
    PISO public token;
    address public owner = address(0x123);
    MockRouter public mockRouter;

    function setUp() public {
        // Deploy mock router
        mockRouter = new MockRouter();
        
        vm.startPrank(owner);
        // Deploy token with valid router address
        token = new PISO(address(mockRouter));
        vm.stopPrank();
    }

    function test_FeeManipulation() public {
        console.log("--- BEFORE Tax Set ---");
        // Capture initial tax values (each component separately)
        (uint256 rfiBuyBefore, uint256 marketingBuyBefore, uint256 liquidityBuyBefore, uint256 devBuyBefore, uint256 buybackBuyBefore) = token.taxes();
        (uint256 rfiSellBefore, uint256 marketingSellBefore, uint256 liquiditySellBefore, uint256 devSellBefore, uint256 buybackSellBefore) = token.sellTaxes();
        
        console.log("Initial Buy Taxes:");
        console.log("  rfi:", rfiBuyBefore);
        console.log("  marketing:", marketingBuyBefore);
        console.log("  liquidity:", liquidityBuyBefore);
        console.log("  dev:", devBuyBefore);
        console.log("  buyback:", buybackBuyBefore);
        
        console.log("Initial Sell Taxes:");
        console.log("  rfi:", rfiSellBefore);
        console.log("  marketing:", marketingSellBefore);
        console.log("  liquidity:", liquiditySellBefore);
        console.log("  dev:", devSellBefore);
        console.log("  buyback:", buybackSellBefore);
        
        console.log("--- Trigger: setTaxes / setSellTaxes ---");
        // Verify owner can set taxes beyond 25% limit
        vm.prank(owner);
        token.setTaxes(10, 10, 10, 10, 10); // Total 50%
        console.log("setTaxes(10,10,10,10,10) called");
        
        vm.prank(owner);
        token.setSellTaxes(20, 20, 20, 20, 20); // Total 100%
        console.log("setSellTaxes(20,20,20,20,20) called");
        
        console.log("--- AFTER Tax Set ---");
        // Capture new tax values (each component separately)
        (uint256 rfiBuyAfter, uint256 marketingBuyAfter, uint256 liquidityBuyAfter, uint256 devBuyAfter, uint256 buybackBuyAfter) = token.taxes();
        (uint256 rfiSellAfter, uint256 marketingSellAfter, uint256 liquiditySellAfter, uint256 devSellAfter, uint256 buybackSellAfter) = token.sellTaxes();
        
        console.log("New Buy Taxes:");
        console.log("  rfi:", rfiBuyAfter);
        console.log("  marketing:", marketingBuyAfter);
        console.log("  liquidity:", liquidityBuyAfter);
        console.log("  dev:", devBuyAfter);
        console.log("  buyback:", buybackBuyAfter);
        
        console.log("New Sell Taxes:");
        console.log("  rfi:", rfiSellAfter);
        console.log("  marketing:", marketingSellAfter);
        console.log("  liquidity:", liquiditySellAfter);
        console.log("  dev:", devSellAfter);
        console.log("  buyback:", buybackSellAfter);
        
        // Verify taxes were set to attack parameters
        bool buyTaxesSetCorrectly = (
            rfiBuyAfter == 10 &&
            marketingBuyAfter == 10 &&
            liquidityBuyAfter == 10 &&
            devBuyAfter == 10 &&
            buybackBuyAfter == 10
        );
        
        bool sellTaxesSetCorrectly = (
            rfiSellAfter == 20 &&
            marketingSellAfter == 20 &&
            liquiditySellAfter == 20 &&
            devSellAfter == 20 &&
            buybackSellAfter == 20
        );
        
        console.log("--- Verification ---");
        console.log("Buy taxes set to 10s:", buyTaxesSetCorrectly ? "true" : "false");
        console.log("Sell taxes set to 20s:", sellTaxesSetCorrectly ? "true" : "false");
        
        // Final vulnerability determination
        if (buyTaxesSetCorrectly && sellTaxesSetCorrectly) {
            console.log("Vulnerability Exists: Owner successfully set taxes beyond 25%% limits");
        } else {
            console.log("Vulnerability not Exist: Owner failed to set taxes beyond limits or values not applied");
        }
    }

    function test_NonOwnerCannotSetFees() public {
        address attacker = address(0x999);
        
        // Verify non-owners cannot set fees
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setTaxes(1, 1, 1, 1, 1);
        
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setSellTaxes(1, 1, 1, 1, 1);
    }
}