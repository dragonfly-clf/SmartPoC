// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PISO.sol";

contract MockWETH {
    function deposit() external payable {}
    function transfer(address to, uint value) external returns (bool) {}
    function withdraw(uint) external {}
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234);
    }
}

contract MockRouter {
    MockFactory public factory;
    address public immutable WETH;

    constructor(address _weth) {
        factory = new MockFactory();
        WETH = _weth;
    }

    function addLiquidityETH(
        address,
        uint,
        uint,
        uint,
        address,
        uint
    ) external payable returns (uint, uint, uint) {}
}

contract PISO_setTaxes_Test is Test {
    PISO public token;
    MockRouter public router;
    address owner = address(0x1);
    address attacker = address(0x2);

    function setUp() public {
        MockWETH weth = new MockWETH();
        router = new MockRouter(address(weth));
        
        vm.prank(owner);
        token = new PISO(address(router));
    }

    // Test to verify only owner can set taxes
    function test_ownerCanSetTaxes() public {
        vm.startPrank(owner);
        token.setTaxes(1, 2, 3, 4, 5);
        
        (uint256 rfi, uint256 marketing, uint256 liquidity, uint256 dev, uint256 buyback) = token.taxes();
        assertEq(rfi, 1, "rfi tax not set");
        assertEq(marketing, 2, "marketing tax not set");
        assertEq(liquidity, 3, "liquidity tax not set");
        assertEq(dev, 4, "dev tax not set");
        assertEq(buyback, 5, "buyback tax not set");
        vm.stopPrank();
    }

    // Test to verify non-owner cannot set taxes
    function test_NonOwnerCannotSetTaxes() public {
        // Record initial tax values for comparison
        (uint256 rfiBefore, uint256 marketingBefore, uint256 liquidityBefore, uint256 devBefore, uint256 buybackBefore) = token.taxes();

        console.log("--- BEFORE-Trigger ---");
        console.log("Initial Taxes:");
        console.log("- RFI:     ", rfiBefore);
        console.log("- Marketing:", marketingBefore);
        console.log("- Liquidity:", liquidityBefore);
        console.log("- Dev:     ", devBefore);
        console.log("- Buyback: ", buybackBefore);

        console.log("--- Trigger (Unauthorized setTaxes Call) ---");
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setTaxes(5, 5, 5, 5, 5);

        console.log("--- AFTER-Trigger ---");
        (uint256 rfiAfter, uint256 marketingAfter, uint256 liquidityAfter, uint256 devAfter, uint256 buybackAfter) = token.taxes();
        console.log("Updated Taxes:");
        console.log("- RFI:     ", rfiAfter);
        console.log("- Marketing:", marketingAfter);
        console.log("- Liquidity:", liquidityAfter);
        console.log("- Dev:     ", devAfter);
        console.log("- Buyback: ", buybackAfter);

        // Check if tax values remain unchanged after unauthorized call
        bool unchanged = (rfiBefore == rfiAfter) && 
                         (marketingBefore == marketingAfter) && 
                         (liquidityBefore == liquidityAfter) && 
                         (devBefore == devAfter) && 
                         (buybackBefore == buybackAfter);
        
        // Print final vulnerability assessment
        if (unchanged) {
            console.log("Vulnerability not Exist: Non-owner unable to change taxes (permission check)");
        } else {
            console.log("Vulnerability Exist: Non-owner has changed taxes without permission");
        }
    }
}