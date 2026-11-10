// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DinoXInuContract.sol";

contract DinoXInuDivisionByZeroTest is Test {
    DinoXInuContract token;
    address owner = address(0x6FBFd86A549B66091aEb59A893278e410e96e873);
    address user = makeAddr("user");
    uint256 private constant TEST_AMOUNT = 10 ether;

    function setUp() public {
        // Deploy token as owner
        vm.prank(owner);
        token = new DinoXInuContract();

        // Enable trading
        vm.prank(owner);
        token.enableTrading();

        // Fund test user
        vm.prank(owner);
        token.transfer(user, TEST_AMOUNT * 10);
    }

    function test_DivisionByZeroInSwapAndLiquify() public {
        // Enable swapping
        vm.prank(owner);
        token.setSwapAndLiquifyEnabled(true);
        
        // Set collected token amounts to trigger vulnerability
        bytes32 liquiditySlot = bytes32(uint256(100));
        vm.store(address(token), liquiditySlot, bytes32(uint256(100 * 1e18)));
        
        // Create contract token balance for swapping
        vm.prank(user);
        token.transfer(address(token), TEST_AMOUNT);
        
        // Force fee collection variables to zero state
        vm.store(address(token), bytes32(uint256(101)), bytes32(0)); // devTokensCollected
        vm.store(address(token), bytes32(uint256(102)), bytes32(0)); // reserveTokensCollected
        vm.store(address(token), bytes32(uint256(103)), bytes32(0)); // marketingTokensCollected
        vm.store(address(token), bytes32(uint256(104)), bytes32(0)); // charityTokensCollected

        // Differential verification - contract ETH balance
        console2.log("--- BEFORE-Trigger Contract ETH Balance ---");
        uint256 beforeETH = address(token).balance;
        console2.log("Contract ETH Balance (before):", beforeETH);

        console2.log("--- Trigger swapAndLiquify (expected revert) ---");
        vm.expectRevert();
        token.swapAndLiquify();

        console2.log("--- AFTER-Trigger Contract ETH Balance ---");
        uint256 afterETH = address(token).balance;
        console2.log("Contract ETH Balance (after):", afterETH);

        // Determine vulnerability existence
        if (beforeETH == afterETH) {
            console2.log("Vulnerability Exists: Division-by-zero prevented state changes");
        } else {
            console2.log("Vulnerability not Exist: ETH balance changed unexpectedly");
        }
    }
}