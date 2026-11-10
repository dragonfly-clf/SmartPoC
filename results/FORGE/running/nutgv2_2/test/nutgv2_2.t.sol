// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/NUTGAIN.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x789);
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory) {
        factory = _factory;
        WETH = address(0x456);
    }
}

contract NUTGAINBlacklistTest is Test {
    NUTGAIN token;
    address owner = vm.addr(1);
    address alice = vm.addr(2);
    address bob = vm.addr(3);
    uint256 constant TOTAL_SUPPLY = 1_500_000_000 * 1e9; // Total supply with decimals

    function setUp() public {
        vm.startPrank(owner);
        
        // Deploy mock Uniswap components
        MockFactory factory = new MockFactory();
        MockRouter router = new MockRouter(address(factory));
        
        // Deploy token contract
        token = new NUTGAIN(address(router));
        
        // Configure token settings
        token.setTradingStatus(true, 0, 0, 0, 0, 0, 0, 0);
        token.updateCooldown(false, 0); // Disable cooldown feature
        token.updateMaxTxLimit(TOTAL_SUPPLY, TOTAL_SUPPLY);
        token.updateMaxWalletlimit(TOTAL_SUPPLY);
        
        // Transfer initial tokens to test accounts
        uint256 initAmount = 100 * 1e9; // 100 tokens with decimals
        token.transfer(alice, initAmount);
        vm.stopPrank();
    }

    function testBlacklistPreventsTransfers() public {
        uint256 transferAmount = 10 * 1e9; // 10 tokens with decimals
        
        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 preTransferBalance = token.balanceOf(bob);
        console.log("[PRE] Bob's balance:", preTransferBalance);

        // Pre-blacklist transfer should succeed
        vm.prank(alice);
        token.transfer(bob, transferAmount);
        
        console.log("--- AFTER-PreBlacklist Transfer ---");
        uint256 postNormalBalance = token.balanceOf(bob);
        uint256 receivedNormal = postNormalBalance - preTransferBalance;
        console.log("[POST] Bob's balance:", postNormalBalance);
        console.log("Received tokens:", receivedNormal);
        assertEq(receivedNormal, transferAmount, "Bob should receive tokens before blacklist");

        console.log("--- Trigger Blacklist ---");
        address[] memory accounts = new address[](1);
        accounts[0] = alice;
        vm.prank(owner);
        token.bulkIsBlacklisted(accounts, true);
        console.log("ACTION: Blacklisted Alice");

        console.log("--- BEFORE-PostBlacklist Transfer ---");
        uint256 preBlacklistBalance = token.balanceOf(bob);
        console.log("[PRE] Bob's balance:", preBlacklistBalance);

        // Transfer attempt from blacklisted account should revert
        vm.prank(alice);
        vm.expectRevert("You are a bot");
        token.transfer(bob, transferAmount);
        
        console.log("--- AFTER-PostBlacklist Transfer ---");
        uint256 postBlacklistBalance = token.balanceOf(bob);
        uint256 receivedAfterBlacklist = postBlacklistBalance - preBlacklistBalance;
        console.log("[POST] Bob's balance:", postBlacklistBalance);
        console.log("Received tokens:", receivedAfterBlacklist);
        
        // Vulnerability verification
        bool vulnerabilityExists = (receivedNormal > 0) && (receivedAfterBlacklist == 0);
        console.log(
            "Vulnerability Exists: ", 
            vulnerabilityExists ? "Yes (blacklist blocked transfer)" : "No (transfer succeeded unexpectedly)"
        );
        
        // Final verdict
        require(vulnerabilityExists, "Vulnerability verification failed");
        console.log("Vulnerability Exists: Blacklist feature prevents transfers from blacklisted account as expected");
    }
}