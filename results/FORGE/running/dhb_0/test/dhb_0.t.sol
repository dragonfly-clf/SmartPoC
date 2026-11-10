// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DemonHellboy.sol";

contract MockWETH {}

contract MockPair {}

contract MockFactory {
    address public immutable pair;

    constructor(address _pair) {
        pair = _pair;
    }

    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _WETH) {
        factory = _factory;
        WETH = _WETH;
    }

    // Implement missing router function for getAmountsOut
    function getAmountsOut(uint256, address[] calldata) external pure returns (uint256[] memory amounts) {
        amounts = new uint256[](2);
        amounts[0] = 1;  // Minimal output to avoid errors
        amounts[1] = 1;  // Minimal output to avoid errors
        return amounts;
    }
}

contract DemonHellboyTest is Test {
    DemonHellboy token;
    address owner = address(0x1);
    address alice = address(0x2);
    address bob = address(0x3);
    
    MockWETH weth;
    MockPair pair;
    MockFactory factory;
    MockRouter router;

    function setUp() public {
        // Deploy mock environment
        weth = new MockWETH();
        pair = new MockPair();
        factory = new MockFactory(address(pair));
        router = new MockRouter(address(factory), address(weth));
        
        // Override hardcoded router address
        vm.etch(0x10ED43C718714eb63d5aA57B78B54704E256024E, address(router).code);

        vm.startPrank(owner);
        token = new DemonHellboy();
        token.setMaxTxAmount(token.totalSupply());  // Disable tx limits initially
        token.transfer(address(pair), 100 * 10**9); // Transfer tokens in decimal units
        token.transfer(alice, 1000 * 10**9);        // Transfer tokens in decimal units
        vm.stopPrank();
    }

    function test_maxTxAmountZeroLock() public {
        // Set maxTxAmount to zero
        vm.prank(owner);
        token.setMaxTxAmount(0);

        // Verify non-owner transfer blocked
        vm.prank(alice);
        vm.expectRevert("Transfer amount exceeds the maxTxAmount.");
        token.transfer(bob, 1);

        // Verify owner can still transfer
        vm.prank(owner);
        token.transfer(bob, 100 * 10**9);
    }

    function test_honeypotHighSellFees() public {
        // Set extreme sell fees
        vm.prank(owner);
        token.setSellFee(99, 1);

        console.log("--- BEFORE-Trigger State SnapShot ---");
        // Record initial balances
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 pairBalanceBefore = token.balanceOf(address(pair));
        console.log("Alice token balance (BEFORE):", aliceBalanceBefore);
        console.log("Pair token balance (BEFORE):", pairBalanceBefore);

        console.log("--- Trigger: Alice transferring entire balance to pair ---");
        // Attempt token transfer to pair
        vm.prank(alice);
        token.transfer(address(pair), aliceBalanceBefore);

        console.log("--- AFTER-Trigger State SnapShot ---");
        // Get new balances
        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 pairBalanceAfter = token.balanceOf(address(pair));
        console.log("Alice token balance (AFTER):", aliceBalanceAfter);
        console.log("Pair token balance (AFTER):", pairBalanceAfter);

        // Calculate state changes
        uint256 aliceLoss = aliceBalanceBefore - aliceBalanceAfter;
        uint256 pairGain = pairBalanceAfter - pairBalanceBefore;
        console.log("Alice tokens lost:", aliceLoss);
        console.log("Pair tokens gained:", pairGain);

        // Vulnerability verdict
        if (aliceBalanceAfter == 0 && pairGain == 0) {
            console.log("Vulnerability Exists: Alice lost all tokens and Pair gained zero tokens (100% fee captured)");
        } else {
            console.log("Vulnerability not Exist: Token transfer did not result in 100% fee capture");
        }

        // Verify honeypot effect
        assertEq(aliceBalanceAfter, 0, "All tokens taken from Alice");
        assertEq(pairBalanceAfter, pairBalanceBefore, "Pair received no tokens - 100% fee captured");
    }
}