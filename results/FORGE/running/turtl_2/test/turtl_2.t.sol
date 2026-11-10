// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/NINJATURTLES.sol";

contract BlacklistTest is Test {
    NINJATURTLES token;
    address deployer = address(this);
    address alice = address(0x1);
    address bob = address(0x2);
    uint256 constant INITIAL_SUPPLY = 1_000_000 * 10 ** 18;

    function setUp() public {
        // Deploy token
        token = new NINJATURTLES();

        // Grant test contract manager role
        bytes32 MANAGER_ROLE = token.MANAGEMENT_ROLE();
        token.grantRole(MANAGER_ROLE, deployer);

        // Assign tokens directly to Alice
        deal(address(token), alice, INITIAL_SUPPLY);
    }

    // Existing function remains unchanged
    function testBlacklistPreventsTransfer() public {
        // Verify Alice's initial balance
        assertEq(token.balanceOf(alice), INITIAL_SUPPLY, "Alice should have tokens");

        // Blacklist Alice
        token.setIsBlacklisted(alice, true);
        assertTrue(token.isBlacklisted(alice), "Alice should be blacklisted");

        // Attempt transfer as Alice
        vm.startPrank(alice);
        uint256 amount = 1_000;

        // Expect revert when blacklisted
        vm.expectRevert(); // Generic revert since exact message isn't known
        token.transfer(bob, amount);
        vm.stopPrank();
    }

    // Existing function remains unchanged
    function testUnauthorizedBlacklistAttempt() public {
        // Non-manager tries to blacklist
        vm.startPrank(alice);
        vm.expectRevert("!PERMISSION");
        token.setIsBlacklisted(bob, true);
        vm.stopPrank();
    }

    // Differential validation test added for before/after state comparison
    function testDifferentialBlacklistStateChange() public {
        uint256 amount = 1_000;

        console.log("--- BEFORE-Trigger State Snapshot ---");
        bool beforeBlacklisted = token.isBlacklisted(alice);
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 bobBalanceBefore = token.balanceOf(bob);

        console.log("Alice isBlacklisted before:", beforeBlacklisted);
        console.log("Alice balance before:", aliceBalanceBefore);
        console.log("Bob balance before:", bobBalanceBefore);

        console.log("--- Trigger: call setIsBlacklisted(alice, true) ---");
        token.setIsBlacklisted(alice, true);

        console.log("--- AFTER-Trigger State Snapshot ---");
        bool afterBlacklisted = token.isBlacklisted(alice);
        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 bobBalanceAfter = token.balanceOf(bob);

        console.log("Alice isBlacklisted after:", afterBlacklisted);
        console.log("Alice balance after:", aliceBalanceAfter);
        console.log("Bob balance after:", bobBalanceAfter);

        console.log("--- Post-Trigger Transfer Attempt ---");
        vm.prank(alice);
        (bool transferSuccess, ) = address(token).call(
            abi.encodeWithSelector(token.transfer.selector, bob, amount)
        );

        console.log("Alice transfer succeeded:", transferSuccess);
        console.log("Alice balance after transfer attempt:", token.balanceOf(alice));
        console.log("Bob balance after transfer attempt:", token.balanceOf(bob));

        bool stateChanged = (afterBlacklisted != beforeBlacklisted);
        bool balancesUnchanged = (
            token.balanceOf(alice) == aliceBalanceBefore &&
            token.balanceOf(bob) == bobBalanceBefore
        );
        bool exploitSuccessful = stateChanged && afterBlacklisted && !transferSuccess && balancesUnchanged;

        console.log("--- Differential Verdict ---");
        console.log("Blacklist state changed:", stateChanged);
        console.log("Transfer blocked:", !transferSuccess);
        console.log("Balances unchanged:", balancesUnchanged);

        if (exploitSuccessful) {
            console.log("Vulnerability Exists: setIsBlacklisted changed Alice's blacklist state and prevented her token transfer");
        } else {
            console.log("Vulnerability not Exist: blacklist state did not change as expected or transfer was not prevented");
        }
    }
}