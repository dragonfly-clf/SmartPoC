// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Play2Burn.sol";

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0x1234567890123456789012345678901234567890);
    }
    
    function WETH() external pure returns (address) {
        return address(0x0000000000000000000000000000000000000002);
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x0000000000000000000000000000000000000003);
    }
}

contract Play2BurnTest is Test {
    Play2Burn public token;
    address public owner;
    
    function setUp() public {
        owner = makeAddr("owner");
        
        // Deploy mock contracts
        MockRouter mockRouter = new MockRouter();
        MockFactory mockFactory = new MockFactory();
        
        // Override PancakeSwap router address with mock code
        address pancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        vm.etch(pancakeRouter, address(mockRouter).code);
        
        // Override mock factory address
        address factoryAddress = address(0x1234567890123456789012345678901234567890);
        vm.etch(factoryAddress, address(mockFactory).code);
        
        // Deploy token contract
        vm.startPrank(owner);
        token = new Play2Burn();
        vm.stopPrank();
    }
    
    function testCannotUpdateRouterAfterRenounceOwnership() public {
        // Verify initial ownership
        assertEq(token.owner(), owner, "Owner should be setup address");
        
        // Deploy mock routers for testing
        MockRouter newRouterContract1 = new MockRouter();
        MockRouter newRouterContract2 = new MockRouter();
        address newRouter1 = address(newRouterContract1);
        address newRouter2 = address(newRouterContract2);
        
        console.log("--- BEFORE-Trigger UpdateRouter ---");
        address initialRouter = address(token.uniswapV2Router());
        console.log("Initial router address:", initialRouter);
        
        // Owner updates router to new valid contract
        vm.prank(owner);
        token.updateRouter(newRouter1);
        console.log("Trigger Operation: Owner updated router to", newRouter1);
        
        // Verify update
        address updatedRouter = address(token.uniswapV2Router());
        console.log("Current router address:", updatedRouter);
        assertEq(updatedRouter, newRouter1, "Router should be updated");
        
        console.log("--- Trigger RenounceOwnership ---");
        vm.prank(owner);
        token.renounceOwnership();
        console.log("Ownership renounced by owner");
        assertEq(token.owner(), address(0), "Ownership should be zero address");
        
        console.log("--- AFTER-Trigger UpdateRouter ---");
        console.log("State before malicious update attempt:");
        address preAttackRouter = address(token.uniswapV2Router());
        console.log("Router address:", preAttackRouter);
        
        // Attempt malicious update (should revert)
        vm.prank(owner);
        console.log("Trigger Operation: Attacker attempts update to", newRouter2);
        vm.expectRevert("Ownable: caller is not the owner");
        token.updateRouter(newRouter2);
        
        // Verify router remains unchanged
        address postAttackRouter = address(token.uniswapV2Router());
        console.log("Router address after attack attempt:", postAttackRouter);
        
        // Final verification
        bool routerUnchanged = postAttackRouter == preAttackRouter;
        if (routerUnchanged) {
            console.log("Vulnerability not Exist: Ownership renunciation prevents router changes");
        } else {
            console.log("Vulnerability Exists: Router changed after ownership renunciation");
        }
    }
}