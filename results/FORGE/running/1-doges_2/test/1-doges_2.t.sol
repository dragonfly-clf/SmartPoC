// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DogeSuperman.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1111111111111111111111111111111111111111);
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract DogeSupermanBlacklistTest is Test {
    DogeSuperman token;
    address owner = 0xE536307a914BCE3dc231F8ca30e5e19D72F460fb;
    address alice = address(0x1);
    address bob = address(0x2);
    address pcsRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address weth = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function setUp() public {
        // Deploy mock infrastructure
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory), weth);
        vm.etch(pcsRouter, address(mockRouter).code);
        
        // Deploy token
        token = new DogeSuperman();
        
        // Configure token
        vm.startPrank(owner);
        token.blacklist_Switch(true); // Enable blacklist enforcement
        token._set_Fees(0, 0);        // Disable fees
        token.set_Max_Transaction_Percent(10000);
        token.set_Max_Wallet_Percent(10000);
        
        // Fund Alice only (Bob starts with 0 balance)
        uint256 totalSupply = token.totalSupply();
        token.transfer(alice, totalSupply / 10); // Transfer 10% to Alice (1e29)
        vm.stopPrank();
    }

    function testBlacklistBlocksTransfer() public {
        uint256 initialAlice = token.balanceOf(alice);
        uint256 initialBob = token.balanceOf(bob);
        uint256 transferAmount = initialAlice / 2; // 5e28
        address[] memory walletToBlacklist = new address[](1);
        walletToBlacklist[0] = alice;

        // Pre-test: Alice transfers to Bob
        vm.prank(alice);
        token.transfer(bob, transferAmount);
        assertEq(
            token.balanceOf(bob),
            initialBob + transferAmount,
            "Pre-blacklist transfer failed"
        );

        // Owner blacklists Alice
        vm.prank(owner);
        token.blacklist_Add_Wallets(walletToBlacklist);

        // Attempt transfer from Alice while blacklisted - should revert
        vm.prank(alice);
        vm.expectRevert();
        token.transfer(bob, transferAmount);
        
        // Verify balances remain unchanged
        assertEq(
            token.balanceOf(alice),
            initialAlice - transferAmount,
            "Alice balance changed unexpectedly"
        );
        assertEq(
            token.balanceOf(bob),
            initialBob + transferAmount,
            "Bob balance changed unexpectedly"
        );
    }

    function testBlacklistRemoval() public {
        uint256 initialAlice = token.balanceOf(alice);
        uint256 initialBob = token.balanceOf(bob);
        uint256 transferAmount = initialAlice / 4; // 2.5e28
        address[] memory addresses = new address[](1);
        addresses[0] = alice;

        // Blacklist Alice
        vm.prank(owner);
        token.blacklist_Add_Wallets(addresses);

        // Remove Alice from blacklist
        vm.prank(owner);
        token.blacklist_Remove_Wallets(addresses);

        // Should be able to transfer after removal
        vm.prank(alice);
        token.transfer(bob, transferAmount);
        assertEq(
            token.balanceOf(bob),
            initialBob + transferAmount,
            "Bob didn't receive tokens"
        );
        assertEq(
            token.balanceOf(alice),
            initialAlice - transferAmount,
            "Alice tokens not deducted"
        );
    }

    function testBlacklistStateChanges() public {
        address[] memory addresses = new address[](1);
        addresses[0] = alice;

        // Validate initial state
        assertFalse(token._isBlacklisted(alice), "Alice incorrectly blacklisted");

        // Owner blacklists Alice
        vm.prank(owner);
        token.blacklist_Add_Wallets(addresses);
        assertTrue(token._isBlacklisted(alice), "Alice not blacklisted");

        // Remove from blacklist
        vm.prank(owner);
        token.blacklist_Remove_Wallets(addresses);
        assertFalse(token._isBlacklisted(alice), "Alice not removed");

        console.log("Vulnerability Exists: Blacklist privilege allows owner to arbitrarily block transfers");
    }
}