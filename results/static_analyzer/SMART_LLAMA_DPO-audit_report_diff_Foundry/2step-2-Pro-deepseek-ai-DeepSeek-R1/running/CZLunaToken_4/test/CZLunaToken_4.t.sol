// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CZLunaToken.sol";

contract CZLunaTokenPrivilegeTest is Test {
    CZLunaToken public token;
    address public owner = vm.addr(1);
    
    address constant ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    // Mock addresses
    address MOCK_FACTORY = address(0x123);
    address MOCK_WETH = address(0x456);
    address MOCK_PAIR = address(0x789);

    function setUp() public {
        vm.startPrank(owner);
        
        // Mock factory() call - selector: 0xc45a0155
        vm.mockCall(
            ROUTER_ADDR,
            abi.encodeWithSelector(bytes4(0xc45a0155)),
            abi.encode(MOCK_FACTORY)
        );
        
        // Mock WETH() call - selector: 0xad5c4648
        vm.mockCall(
            ROUTER_ADDR,
            abi.encodeWithSelector(bytes4(0xad5c4648)),
            abi.encode(MOCK_WETH)
        );
        
        // Mock createPair() call - selector: 0xc9c65396
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSelector(bytes4(0xc9c65396)),
            abi.encode(MOCK_PAIR)
        );
        
        token = new CZLunaToken();
        vm.stopPrank();
    }

    function test_owner_can_set_max_dev_fee() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialFee = token._DevWalletFee();
        console.log("Initial DevWalletFee:", initialFee);

        console.log("--- Trigger Action: setDevWalletFeePercent ---");
        vm.prank(owner);
        token.setDevWalletFeePercent(10); // Max allowed value

        console.log("--- AFTER-Trigger State ---");
        uint256 updatedFee = token._DevWalletFee();
        console.log("Updated DevWalletFee:", updatedFee);

        if (updatedFee == 10) {
            console.log("Vulnerability Exists: Owner modified dev fee beyond design limits");
        } else {
            console.log("Vulnerability not Exist: Dev fee remains within design parameters");
        }
    }

    function test_owner_can_set_max_liquidity_fee() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialFee = token._liquidityFee();
        console.log("Initial LiquidityFee:", initialFee);

        console.log("--- Trigger Action: setLiquidityFeePercent ---");
        vm.prank(owner);
        token.setLiquidityFeePercent(8); // Max allowed value

        console.log("--- AFTER-Trigger State ---");
        uint256 updatedFee = token._liquidityFee();
        console.log("Updated LiquidityFee:", updatedFee);

        if (updatedFee == 8) {
            console.log("Vulnerability Exists: Owner modified liquidity fee beyond design limits");
        } else {
            console.log("Vulnerability not Exist: Liquidity fee remains within design parameters");
        }
    }

    function test_owner_can_set_max_restriction_amount() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialAmount = token._maxRestrictionAmount();
        console.log("Initial Restriction Amount:", initialAmount);

        console.log("--- Trigger Action: setRestrictionAmount ---");
        vm.prank(owner);
        token.setRestrictionAmount(type(uint256).max);

        console.log("--- AFTER-Trigger State ---");
        uint256 updatedAmount = token._maxRestrictionAmount();
        console.log("Updated Restriction Amount:", updatedAmount);

        if (updatedAmount == type(uint256).max) {
            console.log("Vulnerability Exists: Owner maxed out restriction amount");
        } else {
            console.log("Vulnerability not Exist: Restriction amount unchanged");
        }
    }

    function test_non_owner_cannot_set_params() public {
        address attacker = vm.addr(2);
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialDevFee = token._DevWalletFee();
        console.log("Initial DevWalletFee:", initialDevFee);

        console.log("--- Trigger Action: setDevWalletFeePercent by non-owner ---");
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setDevWalletFeePercent(10);

        console.log("--- AFTER-Trigger State ---");
        uint256 updatedDevFee = token._DevWalletFee();
        console.log("Current DevWalletFee:", updatedDevFee);

        if (updatedDevFee == initialDevFee) {
            console.log("Vulnerability not Exist: Non-owner access correctly prevented");
        } else {
            console.log("Vulnerability Exists: Non-owner modified contract state");
        }
    }
}