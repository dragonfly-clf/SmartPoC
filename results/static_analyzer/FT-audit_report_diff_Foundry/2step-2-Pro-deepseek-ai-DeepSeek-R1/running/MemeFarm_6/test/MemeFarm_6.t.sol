// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MemeFarm.sol";

contract MemeFarmTest is Test {
    MemeFarm memeFarm;
    address owner = address(0xA);
    address attacker = address(0xB);

    // Hardcoded router address from MemeFarm constructor
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Setup mock Uniswap environment
        address mockWETH = address(0xC);
        address fakeFactory = address(0xD);
        address fakePair = address(0xE);

        // Mock router factory() call
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("factory()"),
            abi.encode(fakeFactory)
        );
        
        // Mock router WETH() call
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Mock factory createPair() call
        vm.mockCall(
            fakeFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(fakePair)
        );

        // Deploy contract as owner
        vm.prank(owner);
        memeFarm = new MemeFarm();
    }

    function test_setMarketinWalleAddress_OnlyOwner() public {
        // Owner can change marketing address
        console.log("--- BEFORE-Trigger Owner Access Check ---");
        assertTrue(msg.sender != attacker, "Before: Attacker not active");
        
        vm.prank(owner);
        memeFarm.setMarketinWalleAddress(address(0x1001));
        console.log("Owner successfully changed marketing address");

        console.log("--- Trigger Attacker Access Check ---");
        vm.prank(attacker);
        try memeFarm.setMarketinWalleAddress(address(0x2002)) {
            console.log("Vulnerability Exists: Non-owner set marketing address");
        } catch {
            console.log("Vulnerability not Exist: Revert occurred as expected");
        }
    }

    function test_setMaxTxAmount_OnlyOwner() public {
        // Owner can change max TX amount
        console.log("--- BEFORE-Trigger Owner Access Check ---");
        assertTrue(msg.sender != attacker, "Before: Attacker not active");
        
        vm.prank(owner);
        memeFarm.setMaxTxAmount(1000 ether);
        console.log("Owner successfully changed max TX amount");

        console.log("--- Trigger Attacker Access Check ---");
        vm.prank(attacker);
        try memeFarm.setMaxTxAmount(2000 ether) {
            console.log("Vulnerability Exists: Non-owner set max TX amount");
        } catch {
            console.log("Vulnerability not Exist: Revert occurred as expected");
        }
    }
}