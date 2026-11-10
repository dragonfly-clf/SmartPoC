// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/junkoInu.sol";

contract JunkoInuBurnTest is Test {
    junkoInu token;
    address owner = makeAddr("owner");
    uint256 initialSupply;

    function setUp() public {
        vm.prank(owner);
        
        // Mock required router functionality for deployment
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address mockFactory = address(0x1001);
        address mockWETH = address(0x2002);
        address mockPair = address(0x3003);
        
        // Mock router factory and WETH functionality
        vm.etch(routerAddress, abi.encodePacked(hex"00")); // Placeholder code
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );
        
        token = new junkoInu();
        initialSupply = token.totalSupply();
    }

    function testOwnerCanBurnTokens() public {
        uint256 burnAmount = 100 * 10**token.decimals(); // 100 tokens
        
        console.log("--- BEFORE-Trigger Burn ---");
        uint256 supplyBefore = token.totalSupply();
        console.log("Total Supply before burn: ", supplyBefore);

        console.log("--- Trigger Burn ---");
        vm.prank(owner);
        token._burn(owner, burnAmount);

        console.log("--- AFTER-Trigger Burn ---");
        uint256 supplyAfter = token.totalSupply();
        console.log("Total Supply after burn: ", supplyAfter);
        uint256 diff = supplyBefore - supplyAfter;
        console.log("Supply difference: ", diff);
        
        // Differential comparison verdict
        if (diff == burnAmount) {
            console.log("Vulnerability Exists: Owner can arbitrarily burn tokens (centralization risk)");
        } else {
            console.log("Vulnerability not Exist: Token supply not reduced as expected");
        }
        
        // Existing assertion unchanged
        assertEq(token.totalSupply(), initialSupply - burnAmount, "Total supply not reduced");
    }

    function testNonOwnerCannotBurn() public {
        uint256 burnAmount = 100 * 10**token.decimals();
        address attacker = makeAddr("attacker");
        
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token._burn(attacker, burnAmount);
    }
}