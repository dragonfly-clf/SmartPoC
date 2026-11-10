// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";

// Mock PinkAntiBot with transfer blocking functionality
contract MockPinkAntiBot {
    bool public transferBlocked;

    function setBlockStatus(bool shouldBlock) external {
        transferBlocked = shouldBlock;
    }

    function onPreTransferCheck(address, address, uint256) external view {
        if (transferBlocked) revert("Blocked by antibot");
    }
}

// Simplified token contract implementing the vulnerability
contract VulnerableToken {
    address public constant owner = address(0x1);
    MockPinkAntiBot public pinkAntiBot;
    bool public antiBotEnabled;
    mapping(address => bool) public feeWhitelist;
    mapping(address => uint256) public balanceOf;
    string public constant name = "Bybet";
    string public constant symbol = "BBET";
    uint256 public totalSupply;

    constructor() {
        // Fixed initialization without immutable variable usage
        uint256 tokenSupply = 1_200_000_000 * 10**18;
        balanceOf[owner] = tokenSupply;
        totalSupply = tokenSupply;
        feeWhitelist[owner] = true;
    }
    
    function _transfer(address from, address to, uint256 amount) internal {
        if (antiBotEnabled) {
            pinkAntiBot.onPreTransferCheck(from, to, amount);
        }
        require(balanceOf[from] >= amount, "Insufficient balance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
    }

    function enbalePinkSaleAntibot(address pbot, bool status) external {
        require(msg.sender == owner, "Only owner");
        pinkAntiBot = MockPinkAntiBot(pbot);
        antiBotEnabled = status;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }
}

contract TokenBlacklistTest is Test {
    VulnerableToken token;
    MockPinkAntiBot antibot;
    address owner = address(0x1);
    address user1 = address(0x2);
    address user2 = address(0x3);

    function setUp() public {
        vm.startPrank(owner);
        token = new VulnerableToken();
        antibot = new MockPinkAntiBot();
        vm.stopPrank();

        // Fund user1 for transfer tests
        vm.prank(owner);
        token.transfer(user1, 1000 * 10**18);
    }

    function test_ownerCanBlockTransfers() public {
        uint256 amount = 100 * 10**18;
        
        // Initial transfer test
        console.log("--- BEFORE-Trigger Blocking ---");
        uint256 user1BalanceBefore = token.balanceOf(user1);
        uint256 user2BalanceBefore = token.balanceOf(user2);
        console.log("user1 balance before transfer:", user1BalanceBefore);
        console.log("user2 balance before transfer:", user2BalanceBefore);

        // Execute first transfer (without blocking)
        vm.prank(user1);
        token.transfer(user2, amount);

        uint256 user1BalanceAfter = token.balanceOf(user1);
        uint256 user2BalanceAfter = token.balanceOf(user2);
        console.log("user1 balance after transfer:", user1BalanceAfter);
        console.log("user2 balance after transfer:", user2BalanceAfter);

        // Verify transfer succeeded
        assertEq(
            user1BalanceAfter, 
            user1BalanceBefore - amount,
            "Initial transfer should succeed"
        );
        assertEq(
            user2BalanceAfter, 
            user2BalanceBefore + amount,
            "Initial transfer should succeed"
        );
        
        console.log("--- Trigger Blocking ---");
        // Enable antibot blocking (vulnerability trigger)
        vm.prank(owner);
        token.enbalePinkSaleAntibot(address(antibot), true);
        antibot.setBlockStatus(true);
        
        console.log("--- AFTER-Trigger Blocking ---");
        uint256 user1BalanceBlockedBefore = token.balanceOf(user1);
        uint256 user2BalanceBlockedBefore = token.balanceOf(user2);
        console.log("user1 balance before blocked transfer:", user1BalanceBlockedBefore);
        console.log("user2 balance before blocked transfer:", user2BalanceBlockedBefore);
        
        // Attempt transfer (should fail)
        vm.prank(user1);
        vm.expectRevert("Blocked by antibot");
        token.transfer(user2, amount);
        
        uint256 user1BalanceBlockedAfter = token.balanceOf(user1);
        uint256 user2BalanceBlockedAfter = token.balanceOf(user2);
        console.log("user1 balance after blocked transfer:", user1BalanceBlockedAfter);
        console.log("user2 balance after blocked transfer:", user2BalanceBlockedAfter);
        
        // Verify balances unchanged = blocking success
        assertEq(
            user1BalanceBlockedBefore, 
            user1BalanceBlockedAfter,
            "Transfer should be blocked"
        );
        assertEq(
            user2BalanceBlockedBefore, 
            user2BalanceBlockedAfter,
            "Transfer should be blocked"
        );
        
        // Final vulnerability verdict
        if (user1BalanceBlockedBefore == user1BalanceBlockedAfter && 
            user2BalanceBlockedBefore == user2BalanceBlockedAfter) {
            console.log("Vulnerability Exists: Owner can arbitrarily block transfers");
        } else {
            console.log("Vulnerability not Exist: Blocking failed to prevent transfer");
        }
    }

    function test_blockingStateCanBeToggled() public {
        // Enable antibot
        vm.prank(owner);
        token.enbalePinkSaleAntibot(address(antibot), true);
        antibot.setBlockStatus(true);

        // Verify blocking works
        vm.prank(user1);
        vm.expectRevert("Blocked by antibot");
        token.transfer(user2, 100 * 10**18);

        // Disable blocking
        antibot.setBlockStatus(false);

        // Verify transfers work again
        vm.prank(user1);
        token.transfer(user2, 100 * 10**18);
        assertEq(token.balanceOf(user2), 100 * 10**18);
    }
}