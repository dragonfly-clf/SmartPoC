// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BabyApe.sol";

// Mock contracts for Uniswap dependencies
contract MockERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    
    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
        decimals = 18;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1);
    }
}

contract MockRouter {
    address public factory;
    address public WETH;
    
    constructor(address factory_, address weth_) {
        factory = factory_;
        WETH = weth_;
    }
}

contract BabyApeBlacklistTest is Test {
    BabyApe babyApe;
    MockERC20 rewardToken;
    MockERC20 weth;
    MockFactory factory;
    MockRouter router;
    
    address owner = address(this);
    address user1 = address(0x1);
    address user2 = address(0x2);
    address bot = address(0x3);
    uint256 initialSupply = 100_000 ether;
    
    function setUp() public {
        // Create mock Uniswap dependencies
        rewardToken = new MockERC20("Reward", "RWRD");
        weth = new MockERC20("WETH", "WETH");
        factory = new MockFactory();
        router = new MockRouter(address(factory), address(weth));
        
        // Deploy BabyApe contract
        babyApe = new BabyApe(
            initialSupply,
            address(rewardToken),
            address(router),
            address(this),   // hldAdmin
            address(0x123),  // hldBurner
            address(0x456)   // migrator
        );
        
        // Configure token limits and exemptions
        babyApe.changeTxLimit(babyApe.totalSupply());
        babyApe.changeWalletLimit(babyApe.totalSupply());
        babyApe.changeIsFeeExempt(user1, true);
        babyApe.changeIsFeeExempt(user2, true);
        
        // Distribute initial tokens
        babyApe.transfer(user1, 10 ether);
        babyApe.transfer(bot, 10 ether);
    }

    function test_botBlacklistedAsSender() public {
        console.log("--- BEFORE-Trigger Sender Transfer ---");
        uint256 botBalanceBefore = babyApe.balanceOf(bot);
        uint256 user2BalanceBefore = babyApe.balanceOf(user2);
        console.log("Bot balance before transfer:", botBalanceBefore);
        console.log("User2 balance before transfer:", user2BalanceBefore);
        
        // Blacklist bot address
        address[] memory botsList = new address[](1);
        botsList[0] = bot;
        babyApe.setBots(botsList);
        
        console.log("--- Trigger botBlacklistedAsSender ---");
        // Attempt transfer from bot to user2 (should revert)
        vm.prank(bot);
        vm.expectRevert();  // Matches require(!bots[sender] && !bots[recipient])
        babyApe.transfer(user2, 1 ether);
        
        console.log("--- AFTER-Trigger Sender Transfer ---");
        uint256 botBalanceAfter = babyApe.balanceOf(bot);
        uint256 user2BalanceAfter = babyApe.balanceOf(user2);
        console.log("Bot balance after transfer:", botBalanceAfter);
        console.log("User2 balance after transfer:", user2BalanceAfter);
        
        // Verify balances remain unchanged
        bool unchanged = (botBalanceAfter == botBalanceBefore) && (user2BalanceAfter == user2BalanceBefore);
        console.log("Balances unchanged after block?", unchanged ? "YES" : "NO");
        assertEq(botBalanceAfter, botBalanceBefore, "Bot balance changed");
        assertEq(user2BalanceAfter, user2BalanceBefore, "User2 balance changed");
        
        // Final vulnerability verdict
        if (unchanged) {
            console.log("Vulnerability Exists: Blacklist effectively blocks bot senders");
        } else {
            console.log("Vulnerability not Exist: Blacklist failed to block transfer");
        }
    }
    
    function test_botBlacklistedAsRecipient() public {
        console.log("--- BEFORE-Trigger Recipient Transfer ---");
        uint256 user1BalanceBefore = babyApe.balanceOf(user1);
        uint256 botBalanceBefore = babyApe.balanceOf(bot);
        console.log("User1 balance before transfer:", user1BalanceBefore);
        console.log("Bot balance before transfer:", botBalanceBefore);
        
        // Blacklist bot address
        address[] memory botsList = new address[](1);
        botsList[0] = bot;
        babyApe.setBots(botsList);
        
        console.log("--- Trigger botBlacklistedAsRecipient ---");
        // Attempt transfer from user1 to bot (should revert)
        vm.prank(user1);
        vm.expectRevert();  // Matches require(!bots[sender] && !bots[recipient])
        babyApe.transfer(bot, 1 ether);
        
        console.log("--- AFTER-Trigger Recipient Transfer ---");
        uint256 user1BalanceAfter = babyApe.balanceOf(user1);
        uint256 botBalanceAfter = babyApe.balanceOf(bot);
        console.log("User1 balance after transfer:", user1BalanceAfter);
        console.log("Bot balance after transfer:", botBalanceAfter);
        
        // Verify balances remain unchanged
        bool unchanged = (user1BalanceAfter == user1BalanceBefore) && (botBalanceAfter == botBalanceBefore);
        console.log("Balances unchanged after block?", unchanged ? "YES" : "NO");
        assertEq(user1BalanceAfter, user1BalanceBefore, "User1 balance changed");
        assertEq(botBalanceAfter, botBalanceBefore, "Bot balance changed");
        
        // Final vulnerability verdict
        if (unchanged) {
            console.log("Vulnerability Exists: Blacklist effectively blocks bot recipients");
        } else {
            console.log("Vulnerability not Exist: Blacklist failed to block transfer");
        }
    }
}