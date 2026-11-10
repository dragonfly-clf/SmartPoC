// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BLACKBEARD_INU.sol";

contract BlacklistTest is Test {
    BLACKBEARD_INU token;
    address private constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private constant WBNB_ADDRESS = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address owner = address(0x1);
    address presaleAddress = 0xb7edE533360438468faf72456D1c794C35E6B97D;
    address user = address(0x2);
    address receiver = address(0x3);
    
    address private constant MOCK_FACTORY = address(0x123);
    address private constant MOCK_PAIR = address(0x456);

    function setUp() public {
        // Mock router factory call
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(IDEXRouter.factory.selector),
            abi.encode(MOCK_FACTORY)
        );
        // Mock router WETH call
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(IDEXRouter.WETH.selector),
            abi.encode(WBNB_ADDRESS)
        );
        // Mock factory createPair call
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSelector(IDEXFactory.createPair.selector,
            WBNB_ADDRESS),
            abi.encode(MOCK_PAIR)
        );

        vm.startPrank(owner);
        token = new BLACKBEARD_INU();
        vm.stopPrank();
    }

    function testBlacklistRestrictsTransfer() public {
        uint256 amount = 100 * (10 ** token.decimals());
        uint256 presaleBalance = token.balanceOf(presaleAddress);
        assertGe(presaleBalance, amount, "Presale has insufficient balance");
        
        // Presale transfers to user
        vm.prank(presaleAddress);
        token.transfer(user, amount);
        assertEq(token.balanceOf(user), amount, "User balance incorrect");
        
        // Check initial blacklist status
        console.log("--- BEFORE-Trigger Blacklist Status ---");
        bool beforeStatus = token.isBlacklisted(user);
        console.log("User blacklist status before:", beforeStatus);
        assertFalse(beforeStatus, "User should not be blacklisted initially");
        
        console.log("--- Trigger Add Blacklist ---");
        // Owner enables blacklist and adds user
        vm.startPrank(owner);
        token.enable_blacklist(true);
        address[] memory accounts = new address[](1);
        accounts[0] = user;
        token.manage_blacklist(accounts, true);
        vm.stopPrank();
        
        // Verify blacklist status changed
        console.log("--- AFTER-Trigger Blacklist Status ---");
        bool afterStatus = token.isBlacklisted(user);
        console.log("User blacklist status after:", afterStatus);
        assertTrue(afterStatus, "User should be blacklisted after being added");
        
        // Test blacklisted transfer
        vm.prank(user);
        vm.expectRevert("Blacklisted");
        token.transfer(receiver, amount);
        
        // Verify transfer didn't occur
        assertEq(token.balanceOf(user), amount, "User balance changed");
        assertEq(token.balanceOf(receiver), 0, "Receiver received tokens");

        // Final vulnerability verdict
        if (afterStatus && !beforeStatus) {
            console.log("Vulnerability Exists: The user was successfully added to blacklist and restricted from transfers");
        } else {
            console.log("Vulnerability not Exist: The user's blacklist status did not change");
        }
    }
}