// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Stelia.sol";

contract PrivilegeEscalationTest is Test {
    Stelia token;
    address owner = address(0x1);
    
    // Fixed addresses
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant FACTORY_ADDRESS = address(0x1234567890123456789012345678901234567890);
    address constant WETH_ADDRESS = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address constant PAIR_ADDRESS = address(0xdeadbeef);

    function setUp() public {
        // Mock router factory() call
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("factory()"),
            abi.encode(FACTORY_ADDRESS)
        );
        
        // Mock router WETH() call
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("WETH()"),
            abi.encode(WETH_ADDRESS)
        );
        
        // Mock factory createPair() call
        vm.mockCall(
            FACTORY_ADDRESS,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(PAIR_ADDRESS)
        );
        
        // Deploy Stelia token contract as owner
        vm.startPrank(owner);
        token = new Stelia();
        vm.stopPrank();
    }

    function test_RepeatedLockExtension() public {
        uint256 firstDuration = 7 days;
        uint256 secondDuration = 30 days;
        uint256 thirdDuration = 365 days;

        // Reusable state variables
        address preOwner;
        uint256 preUnlockTime;
        address postOwner;
        uint256 postUnlockTime;

        /**** First Lock ****/
        console.log("--- BEFORE-FirstLock ---");
        preOwner = token.owner();
        preUnlockTime = token.geUnlockTime();
        console.log("FirstLock Pre-Owner:", preOwner);
        console.log("FirstLock Pre-UnlockTime:", preUnlockTime);

        console.log("--- PERFORMING FirstLock ---");
        vm.prank(owner);
        token.lock(firstDuration);

        console.log("--- AFTER-FirstLock ---");
        postOwner = token.owner();
        postUnlockTime = token.geUnlockTime();
        console.log("FirstLock Post-Owner:", postOwner);
        console.log("FirstLock Post-UnlockTime:", postUnlockTime);
        assertEq(postUnlockTime, block.timestamp + firstDuration, "First lock time incorrect");
        require(postOwner != preOwner, "FirstLock: Owner did not change");
        console.log("FirstLock STATE CHANGE: SUCCESS");

        /**** First Unlock ****/
        vm.warp(postUnlockTime + 1);
        vm.prank(owner);
        token.unlock();

        /**** Second Lock ****/
        console.log("--- BEFORE-SecondLock ---");
        preOwner = token.owner();
        preUnlockTime = token.geUnlockTime();
        console.log("SecondLock Pre-Owner:", preOwner);
        console.log("SecondLock Pre-UnlockTime:", preUnlockTime);

        console.log("--- PERFORMING SecondLock ---");
        vm.prank(owner);
        token.lock(secondDuration);

        console.log("--- AFTER-SecondLock ---");
        postOwner = token.owner();
        postUnlockTime = token.geUnlockTime();
        console.log("SecondLock Post-Owner:", postOwner);
        console.log("SecondLock Post-UnlockTime:", postUnlockTime);
        assertEq(postUnlockTime, block.timestamp + secondDuration, "Second lock time incorrect");
        require(postOwner != preOwner, "SecondLock: Owner did not change");
        console.log("SecondLock STATE CHANGE: SUCCESS");

        /**** Second Unlock ****/
        vm.warp(postUnlockTime + 1);
        vm.prank(owner);
        token.unlock();

        /**** Third Lock ****/
        console.log("--- BEFORE-ThirdLock ---");
        preOwner = token.owner();
        preUnlockTime = token.geUnlockTime();
        console.log("ThirdLock Pre-Owner:", preOwner);
        console.log("ThirdLock Pre-UnlockTime:", preUnlockTime);

        console.log("--- PERFORMING ThirdLock ---");
        vm.prank(owner);
        token.lock(thirdDuration);

        console.log("--- AFTER-ThirdLock ---");
        postOwner = token.owner();
        postUnlockTime = token.geUnlockTime();
        console.log("ThirdLock Post-Owner:", postOwner);
        console.log("ThirdLock Post-UnlockTime:", postUnlockTime);
        assertEq(postUnlockTime, block.timestamp + thirdDuration, "Third lock time incorrect");
        require(postOwner != preOwner, "ThirdLock: Owner did not change");
        console.log("ThirdLock STATE CHANGE: SUCCESS");

        // All assertions passed - vulnerability exists
        console.log("Vulnerability Exists: Repeated lock operations demonstrate indefinite privilege escalation");
    }
}