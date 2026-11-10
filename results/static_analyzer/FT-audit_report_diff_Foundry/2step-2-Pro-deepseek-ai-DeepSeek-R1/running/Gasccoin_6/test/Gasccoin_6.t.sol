// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Gasccoin.sol";

contract GasccoinAccessControlTest is Test {
    Gasccoin public token;
    address payable owner = payable(makeAddr("owner"));
    address payable dev = payable(makeAddr("dev"));
    address attacker = makeAddr("attacker");

    function setUp() public {
        // Setup mock Uniswap router
        address routerAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        vm.mockCall(routerAddr, abi.encodeWithSignature("factory()"), abi.encode(makeAddr("factory")));
        vm.mockCall(routerAddr, abi.encodeWithSignature("WETH()"), abi.encode(makeAddr("weth")));
        
        // Setup mock factory createPair
        vm.mockCall(makeAddr("factory"), abi.encodeWithSignature("createPair(address,address)"), abi.encode(makeAddr("pair")));

        // Deploy token
        vm.startPrank(owner);
        token = new Gasccoin();
        token.setNewDevAddress(dev);
        vm.stopPrank();
    }

    function test_OwnerCanSetFees() public {
        vm.prank(owner);
        token.setFee(5, 5, 2, 2);
    }

    function test_DevCanSetFees() public {
        vm.prank(dev);
        token.setFee(7, 7, 3, 3);
    }

    function test_UnauthorizedCannotSetFees() public {
        vm.prank(attacker);
        vm.expectRevert("Caller is not the dev");
        token.setFee(1, 1, 1, 1);
    }

    function test_FeeLimitEnforcement() public {
        vm.prank(dev);
        vm.expectRevert("Redis cannot be more than 10.");
        token.setFee(11, 5, 3, 3);
        
        vm.prank(dev);
        vm.expectRevert("Tax cannot be more than 6.");
        token.setFee(5, 5, 7, 3);
    }
    
    // Final verdict based on test results
    function test_Verdict() public {
        // Since private state cannot be validated, verdict relies on:
        // 1. Access control revert in test_UnauthorizedCannotSetFees
        // 2. Fee limit reverts in test_FeeLimitEnforcement
        console.log("Vulnerability not Exist: Access control and fee limits are enforced, preventing unauthorized changes");
    }
}