// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Domain.sol";

contract DomainPrivilegeEscalationTest is Test {
    Domain token;
    address owner = address(0x1);
    address attacker = address(0x2);
    address dummyFactory = address(0x1234);
    address dummyWETH = address(0x5678);
    address dummyPair = address(0x9ABC);
    address newPair = address(0x4);
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Mock router/factory dependencies
        vm.mockCall(routerAddress, abi.encodeWithSignature("factory()"), abi.encode(dummyFactory));
        vm.mockCall(routerAddress, abi.encodeWithSignature("WETH()"), abi.encode(dummyWETH));
        vm.mockCall(dummyFactory, abi.encodeWithSignature("createPair(address,address)"), abi.encode(dummyPair));

        // Deploy contract
        vm.startPrank(owner);
        token = new Domain();
        vm.stopPrank();
    }

    function testOwnerCanSetMaxWalletAmount() public {
        uint256 initialSupply = token.totalSupply();
        vm.prank(owner);
        token.setMaxWalletAmount(100); // Sets to 1% of supply
        
        assertEq(token.maxWalletAmount(), initialSupply / 100, "Owner should set max wallet to 1%");
    }

    function testNonOwnerCannotSetMaxWallet() public {
        console.log("--- Trigger: Non-owner calling setMaxWalletAmount ---");
        vm.startPrank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setMaxWalletAmount(100);
        vm.stopPrank();
        
        console.log("Vulnerability not Exist: Proper access control enforced");
    }

    function testOwnerCanSetAMMPair() public {
        vm.startPrank(owner);
        token.setAutomatedMarketMakerPair(newPair, true);
        assertTrue(token.isAutomatedMarketMakerPair(newPair), "Owner should be able to set AMM pair");

        token.setAutomatedMarketMakerPair(newPair, false);
        assertFalse(token.isAutomatedMarketMakerPair(newPair), "Owner should be able to remove AMM pair");
        vm.stopPrank();
    }

    function testNonOwnerCannotSetAMMPair() public {
        console.log("--- Trigger: Non-owner calling setAutomatedMarketMakerPair ---");
        vm.startPrank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setAutomatedMarketMakerPair(newPair, true);
        vm.stopPrank();
        
        console.log("Vulnerability not Exist: Proper access control enforced");
    }
}