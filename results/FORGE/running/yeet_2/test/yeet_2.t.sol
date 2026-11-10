// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/YeetFlokiToken.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234);
    }
}

contract MockRouter {
    address public factory;
    address public immutable weth;
    
    constructor() {
        factory = address(new MockFactory());
        weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
    
    function WETH() external view returns (address) {
        return weth;
    }
}

contract YeetFlokiBotTest is Test {
    YeetFlokiToken token;
    address owner = vm.addr(1);
    address user1 = vm.addr(2);
    address user2 = vm.addr(3);
    address deadAddress = 0x000000000000000000000000000000000000dEaD;

    function setUp() public {
        MockRouter router = new MockRouter();
        vm.startPrank(owner);
        token = new YeetFlokiToken(address(router));
        
        // Disable cooldown and fees
        token.updateCoolDownSettings(false, 0);
        token.setTaxes(0, 0, 0, 0);  // Set all fees to zero
        token.excludeFromFee(user1);
        token.excludeFromFee(user2);
        
        // Initialize token balances
        uint256 mintAmount = 1000 * 10**token.decimals();
        token.transfer(user1, mintAmount);
        token.transfer(user2, mintAmount);
        vm.stopPrank();
    }

    function test_bulkAntiBotBlocksTransfers() public {
        uint256 transferAmount = 100 * 10**token.decimals();
        uint256 initialBalanceUser2 = token.balanceOf(user2);
        
        // Verify initial transfer works
        vm.prank(user1);
        token.transfer(user2, transferAmount);
        
        console.log("--- BEFORE-Trigger isBot status ---");
        bool isBotBefore = token.isBot(user1);
        console.log("isBot status for user1 before:", isBotBefore);

        console.log("--- Trigger bulkAntiBot ---");
        // Owner blacklists user1
        address[] memory bots = new address[](1);
        bots[0] = user1;
        vm.prank(owner);
        token.bulkAntiBot(bots, true);

        console.log("--- AFTER-Trigger isBot status ---");
        bool isBotAfter = token.isBot(user1);
        console.log("isBot status for user1 after:", isBotAfter);

        console.log("State change from %s to %s: %s", isBotBefore ? "true" : "false", isBotAfter ? "true" : "false", (isBotBefore != isBotAfter) ? "SUCCESS" : "FAILURE");

        // Verify user1 cannot send tokens
        vm.prank(user1);
        vm.expectRevert("You are a bot");
        token.transfer(user2, transferAmount);

        // Verify transfers to user1 are blocked
        vm.prank(user2);
        vm.expectRevert("You are a bot");
        token.transfer(user1, transferAmount);

        // Final vulnerability verdict
        if (isBotBefore != isBotAfter) {
            console.log("Vulnerability Exists: isBot state changed from false to true after exploit");
        } else {
            console.log("Vulnerability not Exist: isBot state did not change after exploit");
        }
    }
}