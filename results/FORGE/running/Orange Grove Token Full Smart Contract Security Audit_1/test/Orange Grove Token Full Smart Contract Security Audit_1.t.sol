// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GroveToken.sol";

contract GroveTokenGasTest is Test {
    GroveToken token;
    address owner = address(0x1000);
    address mockRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address mockFactory = address(0x1111);
    address mockWETH = address(0x2222);
    address dummyPair = address(0x3333);
    
    function setUp() public {
        vm.startPrank(owner);
        
        // Mock router factory call
        vm.mockCall(
            mockRouter,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        
        // Mock router WETH call
        vm.mockCall(
            mockRouter,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Mock factory createPair call
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(dummyPair)
        );
        
        token = new GroveToken();
        vm.stopPrank();
    }
    
    function testIncludeInRewardOutOfGas() public {
        // Create large excluded addresses list
        address[] memory addrs = new address[](200);
        for (uint256 i = 0; i < 200; i++) {
            addrs[i] = address(uint160(i + 10000));
        }
        
        // Exclude all addresses from rewards
        vm.startPrank(owner);
        for (uint256 i = 0; i < 200; i++) {
            token.excludeFromReward(addrs[i]);
        }
        vm.stopPrank();
        
        // Attempt to re-include with insufficient gas
        bytes memory payload = abi.encodeWithSignature(
            "includeInReward(address)", 
            addrs[199]
        );
        
        console.log("--- Trigger Operation ---");
        console.log("Calling includeInReward() with 100,000 gas");
        vm.prank(owner);
        (bool success, ) = address(token).call{gas: 100000}(payload);
        
        console.log("--- Result Verification ---");
        console.log("Transaction status:", success ? "SUCCESS" : "FAILED (expected)");
        
        // Vulnerability verdict
        if (!success) {
            console.log("Vulnerability Exists: includeInReward function runs out of gas when processing large excluded address lists");
        } else {
            console.log("Vulnerability not Exist: includeInReward unexpectedly completed with limited gas");
        }
    }
    
    function testGetCurrentSupplyOutOfGas() public {
        // Create large excluded addresses list
        address[] memory addrs = new address[](200);
        for (uint256 i = 0; i < 200; i++) {
            addrs[i] = address(uint160(i + 20000));
        }
        
        // Exclude all addresses from rewards
        vm.startPrank(owner);
        for (uint256 i = 0; i < 200; i++) {
            token.excludeFromReward(addrs[i]);
        }
        vm.stopPrank();
        
        // Attempt balance lookup with low gas (triggers _getCurrentSupply)
        address arbitraryAccount = address(0x1);
        bytes memory payload = abi.encodeWithSignature(
            "balanceOf(address)", 
            arbitraryAccount
        );
        
        console.log("--- Trigger Operation ---");
        console.log("Calling balanceOf() with 100,000 gas");
        (bool success, ) = address(token).staticcall{gas: 100000}(payload);
        
        console.log("--- Result Verification ---");
        console.log("Transaction status:", success ? "SUCCESS" : "FAILED (expected)");
        
        // Vulnerability verdict
        if (!success) {
            console.log("Vulnerability Exists: _getCurrentSupply function runs out of gas when processing large excluded address lists");
        } else {
            console.log("Vulnerability not Exist: _getCurrentSupply unexpectedly completed with limited gas");
        }
    }
}