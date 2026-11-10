// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/YeetFlokiToken.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234); // Changed to avoid conflict with dead address
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract YeetFlokiToken_PrivilegeEscalationTest is Test {
    YeetFlokiToken token;
    address owner = address(0x1);
    address hacker = address(0x666);
    address devWallet = address(0x888);
    address newRouter = address(0xaaa);
    address newPair = address(0xbbb);
    address weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    function setUp() public {
        // Deploy mocks with unique addresses
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory), weth);
        
        vm.startPrank(owner);
        token = new YeetFlokiToken(address(mockRouter));
        token.updatedevWallet(devWallet); // Setup dev wallet explicitly
        vm.stopPrank();
    }

    function test_router_update_to_zero_address() public {
        console.log("--- BEFORE-Trigger ---");
        address currentRouter = address(token.router());
        address currentPair = token.pair();
        console.log("Current Router: %s", currentRouter);
        console.log("Current Pair: %s", currentPair);

        console.log("--- Trigger updateRouterAndPair ---");
        vm.startPrank(owner);
        token.updateRouterAndPair(address(0), newPair);
        vm.stopPrank();

        console.log("--- AFTER-Trigger ---");
        address updatedRouter = address(token.router());
        address updatedPair = token.pair();
        console.log("Updated Router: %s", updatedRouter);
        console.log("Updated Pair: %s", updatedPair);

        // State verification
        bool routerUpdated = updatedRouter == address(0);
        bool pairUpdated = updatedPair == newPair;

        if(routerUpdated && pairUpdated) {
            console.log("Vulnerability not Exist: router and pair updated as intended by owner");
        } else {
            console.log("Vulnerability Exists: unexpected router/pair state after update");
        }
    }
    
    function test_owner_can_set_malicious_router() public {
        console.log("--- BEFORE-Trigger ---");
        address currentRouter = address(token.router());
        address currentPair = token.pair();
        console.log("Current Router: %s", currentRouter);
        console.log("Current Pair: %s", currentPair);

        console.log("--- Trigger updateRouterAndPair ---");
        vm.startPrank(owner);
        token.updateRouterAndPair(hacker, newPair);
        vm.stopPrank();

        console.log("--- AFTER-Trigger ---");
        address updatedRouter = address(token.router());
        address updatedPair = token.pair();
        console.log("Updated Router: %s", updatedRouter);
        console.log("Updated Pair: %s", updatedPair);

        // State verification
        bool maliciousRouterSet = updatedRouter == hacker;
        bool pairUpdated = updatedPair == newPair;
        
        if(maliciousRouterSet && pairUpdated) {
            console.log("Vulnerability not Exist: router updated to malicious address by design (owner action)");
        } else {
            console.log("Vulnerability Exists: unexpected router/pair state after update");
        }
    }
    
    function test_non_owner_cannot_update_router() public {
        console.log("--- BEFORE-Trigger ---");
        address originalRouter = address(token.router());
        address originalPair = token.pair();
        console.log("Original Router: %s", originalRouter);
        console.log("Original Pair: %s", originalPair);

        console.log("--- Trigger updateRouterAndPair ---");
        vm.startPrank(hacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.updateRouterAndPair(newRouter, newPair);
        vm.stopPrank();

        console.log("--- AFTER-Trigger ---");
        address currentRouter = address(token.router());
        address currentPair = token.pair();
        console.log("Current Router: %s", currentRouter);
        console.log("Current Pair: %s", currentPair);

        // State verification
        bool routerUnchanged = currentRouter == originalRouter;
        bool pairUnchanged = currentPair == originalPair;
        
        if(routerUnchanged && pairUnchanged) {
            console.log("Vulnerability not Exist: router and pair state unchanged after unauthorized access");
        } else {
            console.log("Vulnerability Exists: unauthorized router/pair modification detected");
        }
    }
}