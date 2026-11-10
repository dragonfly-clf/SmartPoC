// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ZAX.sol";

contract MockRouter {
    address public factory;
    address public WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234);
    }
}

contract ZAXBlacklistTest is Test {
    ZAX public token;
    address owner = address(0x1);
    address alice = address(0x2);
    address bob = address(0x3);
    address charlie = address(0x4);
    address dave = address(0x5); // New address for transfer verifications

    function setUp() public {
        // Set up mock Uniswap router/factory
        address mockFactory = address(new MockFactory());
        address mockWETH = address(0x456);
        address mockRouter = address(new MockRouter(mockFactory, mockWETH));
        
        // Deploy token contract
        vm.startPrank(owner);
        token = new ZAX(mockRouter);
        
        // Configure contract
        token.setTradingStatus(true, block.timestamp + 1000, 0, 0, 0, 0);
        token.updateCooldown(false, 0); // Disable cooldown for tests
        token.transfer(alice, 1000 * 10**token.decimals());
        token.transfer(charlie, 1000 * 10**token.decimals());
        vm.stopPrank();
    }

    function testBlacklistedAddressCannotTransfer() public {
        uint256 amount = 1 * 10**token.decimals(); // Use small amount
        
        console.log("--- BEFORE-Trigger Blacklist ---");
        uint256 alicePreBalance = token.balanceOf(alice);
        uint256 davePreBalance = token.balanceOf(dave);
        
        // Verify transfers work for non-blacklisted
        vm.prank(alice);
        token.transfer(dave, amount);
        
        uint256 alicePostBalance = token.balanceOf(alice);
        uint256 davePostBalance = token.balanceOf(dave);
        uint256 expectedBalanceAlice = alicePreBalance - amount;
        uint256 expectedBalanceDave = davePreBalance + amount;
        
        console.log("Alice pre-transfer balance:", alicePreBalance);
        console.log("Dave pre-transfer balance:", davePreBalance);
        console.log("Transfer successful: Alice transferred %s tokens to Dave", amount);
        console.log("Alice post-transfer balance:", alicePostBalance);
        console.log("Dave post-transfer balance:", davePostBalance);
        
        assertEq(alicePostBalance, expectedBalanceAlice, "Alice balance incorrect");
        assertEq(davePostBalance, expectedBalanceDave, "Dave balance incorrect");
        
        console.log("--- Trigger Blacklist ---");
        // Blacklist Alice
        vm.prank(owner);
        token.updateIsBlacklisted(alice, true);
        
        console.log("--- AFTER-Trigger Blacklist ---");
        // Record balances before attempted transfer
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 daveBalanceBefore = token.balanceOf(dave);
        console.log("Alice pre-transfer balance:", aliceBalanceBefore);
        console.log("Dave pre-transfer balance:", daveBalanceBefore);
        
        // Try to transfer from blacklisted account
        vm.startPrank(alice);
        vm.expectRevert();
        token.transfer(dave, amount);
        vm.stopPrank();
        
        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 daveBalanceAfter = token.balanceOf(dave);
        console.log("Transfer result: FAILED (as expected for blacklisted)");
        console.log("Alice post-transfer balance:", aliceBalanceAfter);
        console.log("Dave post-transfer balance:", daveBalanceAfter);
        
        // Vulnerability verdict
        string memory verdict;
        if (daveBalanceAfter != daveBalanceBefore || aliceBalanceAfter != aliceBalanceBefore) {
            verdict = "Vulnerability not Exist: Blacklist enforcement failed";
        } else {
            verdict = "Vulnerability Exists: Blacklist enforcement works as intended";
        }
        console.log(verdict);
    }

    function testNonBlacklistedCanTransfer() public {
        uint256 amount = 100 * 10**token.decimals();
        
        // Charlie transfers normally (not blacklisted)
        vm.prank(charlie);
        token.transfer(bob, amount);
        
        // Verify successful transfer
        assertEq(token.balanceOf(charlie), 900 * 10**token.decimals(), "Charlie balance incorrect");
        assertEq(token.balanceOf(bob), amount, "Bob didn't receive tokens");
    }

    function testBulkBlacklistPreventsTransfers() public {
        uint256 amount = 1 * 10**token.decimals();
        address[] memory accounts = new address[](2);
        accounts[0] = alice;
        accounts[1] = charlie;
        
        console.log("--- BEFORE-Trigger Bulk Blacklist ---");
        // Test transfer from Alice -> Dave
        uint256 davePreBalance1 = token.balanceOf(dave);
        vm.prank(alice);
        token.transfer(dave, amount);
        uint256 davePostBalance1 = token.balanceOf(dave);
        console.log("Alice could transfer %s tokens to Dave (balance +%s)", amount, davePostBalance1 - davePreBalance1);
        
        // Test transfer from Charlie -> Dave
        uint256 davePreBalance2 = token.balanceOf(dave);
        vm.prank(charlie);
        token.transfer(dave, amount);
        uint256 davePostBalance2 = token.balanceOf(dave);
        console.log("Charlie could transfer %s tokens to Dave (balance +%s)", amount, davePostBalance2 - davePreBalance2);
        
        console.log("--- Trigger Bulk Blacklist ---");
        // Bulk blacklist Alice and Charlie
        vm.prank(owner);
        token.bulkIsBlacklisted(accounts, true);
        
        console.log("--- AFTER-Trigger Bulk Blacklist ---");
        // Record Dave's balance before transfers
        uint256 daveBalanceBefore = token.balanceOf(dave);
        
        // Attempt transfers from both accounts
        vm.startPrank(alice);
        vm.expectRevert();
        token.transfer(dave, amount);
        vm.stopPrank();
        console.log("Alice's transfer blocked");
        
        vm.startPrank(charlie);
        vm.expectRevert();
        token.transfer(dave, amount);
        vm.stopPrank();
        console.log("Charlie's transfer blocked");
        
        uint256 daveBalanceAfter = token.balanceOf(dave);
        uint256 balanceChange = daveBalanceAfter - daveBalanceBefore;
        
        // Vulnerability verdict
        string memory verdict;
        if (balanceChange > 0) {
            verdict = "Vulnerability not Exist: Bulk blacklist failed to prevent unauthorized transfers";
        } else {
            verdict = "Vulnerability Exists: Bulk blacklist successfully prevented unauthorized transfers";
        }
        console.log(verdict);
    }
}