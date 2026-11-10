// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MetaCore.sol";

contract MetaCoreFeeManipulationTest is Test {
    MetaCore token;
    address owner = address(0x111);
    address marketingWallet = address(0x222);
    uint8 stakingDays = 7;

    // Dummy addresses for Uniswap components
    address dummyRouter = address(0xA11);
    address dummyFactory = address(0xFA);
    address dummyWETH = address(0xB22);
    address dummyPair = address(0xC33);

    function setUp() public {
        // Mock router responses
        vm.mockCall(
            dummyRouter,
            abi.encodeWithSignature("factory()"),
            abi.encode(dummyFactory)
        );
        vm.mockCall(
            dummyRouter,
            abi.encodeWithSignature("WETH()"),
            abi.encode(dummyWETH)
        );

        // Mock factory createPair response
        vm.mockCall(
            dummyFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(dummyPair)
        );

        vm.startPrank(owner);
        token = new MetaCore(marketingWallet, stakingDays, dummyRouter);
        vm.stopPrank();
    }

    function test_OwnerCanSetMarketingFeeToExcessiveValue() public {
        // Before trigger state
        uint256 initialFee = token.marketingFee();
        console.log("--- BEFORE-Trigger ---");
        console.log("Initial marketing fee:", initialFee);

        // Trigger operation
        console.log("--- Trigger SetMarketingFee ---");
        vm.prank(owner);
        token.setMarketingFee(100);
        assertEq(token.marketingFee(), 100, "100% fee set");

        vm.prank(owner);
        token.setMarketingFee(1000);
        assertEq(token.marketingFee(), 1000, "Dangerously high fee set (1000%)");

        // After trigger state
        console.log("--- AFTER-Trigger ---");
        uint256 finalFee = token.marketingFee();
        console.log("Marketing fee after trigger:", finalFee);

        // Vulnerability verdict
        if (finalFee > 100) {
            console.log("Vulnerability Exists: Marketing fee can be set to >100%");
        } else {
            console.log("Vulnerability not Exist: Marketing fee within safe limits");
        }
    }

    function test_NonOwnerCannotSetMarketingFee() public {
        address nonOwner = address(0x999);
        
        // Before trigger state
        uint256 initialFee = token.marketingFee();
        console.log("--- BEFORE-Trigger ---");
        console.log("Initial marketing fee:", initialFee);

        console.log("--- Trigger SetMarketingFee (non-owner attempt) ---");
        vm.prank(nonOwner);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setMarketingFee(10);

        // After trigger state
        console.log("--- AFTER-Trigger ---");
        uint256 finalFee = token.marketingFee();
        console.log("Marketing fee after trigger:", finalFee);
        
        // Vulnerability not exists since revert occurred
        if (finalFee == initialFee) {
            console.log("Vulnerability not Exist: Non-owner could not change marketing fee");
        } else {
            console.log("Vulnerability Exists: Non-owner changed marketing fee");
        }
    }

    function test_NoUpperLimitCheck() public {
        // Before trigger state
        uint256 initialFee = token.marketingFee();
        console.log("--- BEFORE-Trigger ---");
        console.log("Initial marketing fee:", initialFee);

        // Trigger operation
        console.log("--- Trigger SetMaxUintFee ---");
        uint256 maxUint = type(uint256).max;
        vm.prank(owner);
        token.setMarketingFee(maxUint);
        assertEq(token.marketingFee(), maxUint, "Fee set to max uint value");

        // After trigger state
        console.log("--- AFTER-Trigger ---");
        uint256 finalFee = token.marketingFee();
        console.log("Marketing fee after trigger:", finalFee);

        // Vulnerability verdict
        if (finalFee >= maxUint) {
            console.log("Vulnerability Exists: Marketing fee can be set to max uint value");
        } else {
            console.log("Vulnerability not Exist: Marketing fee within uint range");
        }
    }
}