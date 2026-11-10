// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Hospo.sol";

contract MockUniswapV2Factory {
    address public pair;
    
    constructor(address _pair) {
        pair = _pair;
    }
    
    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockUniswapV2Router {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract HospoBlacklistTest is Test {
    Hospo token;
    address owner = address(0xA);
    address user1 = address(0xB);
    address user2 = address(0xC);
    address mockWETH = address(0x123);
    address mockPair = address(0x456);
    address constant uniswapRouter = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    function setUp() public {
        // Setup mock Uniswap environment
        MockUniswapV2Factory mockFactory = new MockUniswapV2Factory(mockPair);
        MockUniswapV2Router mockRouter = new MockUniswapV2Router(address(mockFactory), mockWETH);
        
        // Replace actual router code with mock
        vm.etch(uniswapRouter, address(mockRouter).code);
        vm.label(uniswapRouter, "MockRouter");
        
        // Deploy token
        vm.startPrank(owner);
        token = new Hospo();
        token.startTrading();
        vm.stopPrank();
        
        // Fund mock pair with tokens
        deal(address(token), mockPair, 100_000_000 ether);
    }

    // Test owner can blacklist arbitrary accounts
    function testOwnerBlacklist() public {
        console.log("--- BEFORE-Trigger State (owner blacklist) ---");
        bool beforeStatus = token._isBlackListed(user1);
        console.log("User1 blacklisted (before):", beforeStatus ? "Yes" : "No");
        
        console.log("--- Trigger Operation: owner sets user1 as blacklisted ---");
        vm.prank(owner);
        token.setBlackList(user1, true);
        
        console.log("--- AFTER-Trigger State (owner blacklist) ---");
        bool afterStatus = token._isBlackListed(user1);
        console.log("User1 blacklisted (after):", afterStatus ? "Yes" : "No");
        
        // Vulnerability verdict
        if (afterStatus) {
            console.log("Vulnerability Exists: User1 was successfully blacklisted by owner");
        } else {
            console.log("Vulnerability not Exist: Blacklist status unchanged after owner attempted blacklisting");
        }

        // Attempt token transfer from blacklisted account
        vm.prank(user1);
        vm.expectRevert("Account is blacklisted");
        token.transfer(user2, 1e18);
    }
    
    // Test automatic blacklisting of early buyers
    function testAutomaticEarlyBuyerBlacklist() public {
        console.log("--- BEFORE-Trigger State (early buyer) ---");
        bool beforeStatus = token._isBlackListed(user1);
        console.log("User1 blacklisted (before):", beforeStatus ? "Yes" : "No");
        
        console.log("--- Trigger Operation: early buy transfer from DEX ---");
        vm.prank(mockPair);
        token.transfer(user1, 10 ether);
        
        console.log("--- AFTER-Trigger State (early buyer) ---");
        bool afterStatus = token._isBlackListed(user1);
        console.log("User1 blacklisted (after):", afterStatus ? "Yes" : "No");
        
        // Vulnerability verdict
        if (afterStatus) {
            console.log("Vulnerability Exists: Early buyer automatically blacklisted");
        } else {
            console.log("Vulnerability not Exist: Early buyer not blacklisted after transfer");
        }
        
        // Transfer should be blocked
        vm.prank(user1);
        vm.expectRevert("Account is blacklisted");
        token.transfer(user2, 1 ether);
    }
    
    // Test no automatic blacklisting after vulnerable window
    function testNoBlacklistAfterEarlyWindow() public {
        console.log("--- BEFORE-Trigger State (post-window) ---");
        bool beforeStatus = token._isBlackListed(user1);
        console.log("User1 blacklisted (before):", beforeStatus ? "Yes" : "No");
        
        console.log("--- Trigger Operation: move beyond early window (block.number+101) ---");
        vm.roll(block.number + 101);
        console.log("Current block:", block.number);
        
        console.log("--- Trigger DEX transfer post-window ---");
        vm.prank(mockPair);
        token.transfer(user1, 10 ether);
        
        console.log("--- AFTER-Trigger State (post-window) ---");
        bool afterStatus = token._isBlackListed(user1);
        console.log("User1 blacklisted (after):", afterStatus ? "Yes" : "No");
        
        // Vulnerability verdict
        if (!afterStatus) {
            console.log("Vulnerability not Exist: User1 not blacklisted after early window transfer");
        } else {
            console.log("Vulnerability Exists: User1 incorrectly blacklisted after early window");
        }

        // Transfer should succeed
        vm.prank(user1);
        token.transfer(user2, 1 ether);
        assertEq(token.balanceOf(user2), 1 ether);
    }
}