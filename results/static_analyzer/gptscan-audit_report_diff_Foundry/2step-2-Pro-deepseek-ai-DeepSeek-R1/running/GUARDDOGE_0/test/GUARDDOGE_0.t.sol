// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GUARDDOGE.sol";

// Mock factory contract
contract MockFactory {
    address public immutable pair;
    
    constructor() {
        // Create a fixed mock pair address
        pair = address(0x1234567890123456789012345678901234567890);
    }
    
    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

// Mock router contract implementing the required swap function
contract MockRouter {
    address public immutable factory;
    
    constructor(address _factory) {
        factory = _factory;
    }
    
    // Empty implementation - test only cares about ETH transfer
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint /*amountOutMin*/,
        address[] calldata /*path*/,
        address /*to*/,
        uint /*deadline*/
    ) external payable {
        // No-op: Just receive ETH
    }
}

contract GuardDogeSandwichTest is Test {
    GUARDDOGE token;
    MockRouter mockRouter;
    MockFactory mockFactory;
    
    // Hardcoded addresses from original contract
    address constant HARDCODED_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant WBNB_ADDR = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    uint256 constant ETH_AMOUNT = 1 ether;

    function setUp() public {
        // Create mock infrastructure
        mockFactory = new MockFactory();
        mockRouter = new MockRouter(address(mockFactory));
        
        // Patch real router address with mock bytecode
        vm.etch(HARDCODED_ROUTER, address(mockRouter).code);
        
        // Deploy token contract - will use our mocked router
        token = new GUARDDOGE();
        
        // Authorize this test contract on the token
        token.authorize(address(this));
        
        // Fund token contract with ETH for buyback
        deal(address(token), ETH_AMOUNT);
    }

    function testBuybackUsesVulnerableSwap() public {
        uint256 tokenBalanceBefore = address(token).balance;
        uint256 routerBalanceBefore = HARDCODED_ROUTER.balance;
        
        console.log("--- BEFORE-Trigger Buyback ---");
        console.log("Token contract ETH balance:", tokenBalanceBefore);
        console.log("Router contract ETH balance:", routerBalanceBefore);
        console.log("");
        
        console.log("--- Trigger Buyback ---");
        // Execute vulnerable buyback function
        token.triggerManualBuyback(ETH_AMOUNT, false);
        console.log("");
        
        uint256 tokenBalanceAfter = address(token).balance;
        uint256 routerBalanceAfter = HARDCODED_ROUTER.balance;
        uint256 tokenBalanceDiff = tokenBalanceBefore - tokenBalanceAfter;
        uint256 routerBalanceDiff = routerBalanceAfter - routerBalanceBefore;
        
        console.log("--- AFTER-Trigger Buyback ---");
        console.log("Token contract ETH balance:", tokenBalanceAfter);
        console.log("Router contract ETH balance:", routerBalanceAfter);
        console.log("");
        console.log("Token contract ETH change: -%s", tokenBalanceDiff);
        console.log("Router contract ETH change: +%s", routerBalanceDiff);
        console.log("");
        
        // Vulnerability exists if both transfers match expected ETH_AMOUNT
        bool vulnerabilityExists = (tokenBalanceDiff == ETH_AMOUNT) && 
                                   (routerBalanceDiff == ETH_AMOUNT);
        
        // Final verdict with explicit condition checks
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: ETH was transferred directly to router");
        } else {
            console.log("Vulnerability not Exist: ETH was not transferred as expected");
        }
    }
}