// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/HaggleToken.sol";

contract HaggleTokenTest is Test {
    HaggleXToken token;
    address owner;
    address alice;
    
    uint256 constant STAKE_AMOUNT = 100 ether;
    uint256 constant MINUTES_20 = 20 * 60;
    uint256 constant MINUTES_30 = 30 * 60;

    function setUp() public {
        owner = address(this);
        alice = address(0x123);
        
        token = new HaggleXToken();
        token.setMinter(owner);
        token.mint(alice, 200 ether);
    }

    function testStakeOptionsAccountedIncorrectly() public {
        // Stake with different types
        vm.startPrank(alice);
        token.stake(STAKE_AMOUNT, 9); // Type 9 (20 min lock)
        token.stake(STAKE_AMOUNT, 8); // Type 8 (30 min lock)
        vm.stopPrank();

        // Check initial balances
        assertEq(token.getTotalStakedAmount(9), STAKE_AMOUNT, "Type9 initial mismatch");
        assertEq(token.getTotalStakedAmount(8), STAKE_AMOUNT, "Type8 initial mismatch");
        assertEq(token.getTotalStakedAmount(0), 0, "Type0 initial should be zero");

        // Fast forward past lock periods
        vm.warp(block.timestamp + MINUTES_30 + 1);

        // Capture state BEFORE first unstake
        console.log("--- BEFORE-Trigger First Unstake ---");
        uint256 type0BeforeFirst = token.getTotalStakedAmount(0);
        uint256 type8BeforeFirst = token.getTotalStakedAmount(8);
        uint256 type9BeforeFirst = token.getTotalStakedAmount(9);
        console.log("Type0:", type0BeforeFirst);
        console.log("Type8:", type8BeforeFirst);
        console.log("Type9:", type9BeforeFirst);

        // Trigger first unstake (type9 position)
        console.log("--- Trigger First Unstake ---");
        vm.prank(alice);
        token.unstake(0);

        // Capture state AFTER first unstake
        console.log("--- AFTER-Trigger First Unstake ---");
        uint256 type0AfterFirst = token.getTotalStakedAmount(0);
        uint256 type8AfterFirst = token.getTotalStakedAmount(8);
        uint256 type9AfterFirst = token.getTotalStakedAmount(9);
        console.log("Type0:", type0AfterFirst);
        console.log("Type8:", type8AfterFirst);
        console.log("Type9:", type9AfterFirst);
        
        // Verify type9 unchanged but type0 incorrectly modified
        assertEq(type9AfterFirst, STAKE_AMOUNT, "Type9 should remain unchanged");
        assertTrue(type0AfterFirst != 0, "Type0 incorrectly modified");

        // Capture state BEFORE second unstake
        console.log("--- BEFORE-Trigger Second Unstake ---");
        uint256 type0BeforeSecond = token.getTotalStakedAmount(0);
        uint256 type8BeforeSecond = token.getTotalStakedAmount(8);
        uint256 type9BeforeSecond = token.getTotalStakedAmount(9);
        console.log("Type0:", type0BeforeSecond);
        console.log("Type8:", type8BeforeSecond);
        console.log("Type9:", type9BeforeSecond);
        
        // Trigger second unstake (type8 position)
        console.log("--- Trigger Second Unstake ---");
        vm.prank(alice);
        token.unstake(0);

        // Capture state AFTER second unstake
        console.log("--- AFTER-Trigger Second Unstake ---");
        uint256 finalType0 = token.getTotalStakedAmount(0);
        uint256 finalType8 = token.getTotalStakedAmount(8);
        uint256 finalType9 = token.getTotalStakedAmount(9);
        console.log("Type0:", finalType0);
        console.log("Type8:", finalType8);
        console.log("Type9:", finalType9);

        // Verify both stake types unchanged while type0 accumulates changes
        assertEq(finalType8, STAKE_AMOUNT, "Type8 should remain unchanged");
        assertEq(finalType9, STAKE_AMOUNT, "Type9 should remain unchanged");
        assertTrue(
            finalType0 != type0BeforeSecond,
            "Type0 should have double modification"
        );

        // Final vulnerability verdict: Check if type0 doubled and others unchanged
        bool type0Doubled = finalType0 == type0BeforeFirst + 2 * STAKE_AMOUNT;
        bool typesUnchanged = (finalType8 == type8BeforeFirst) && (finalType9 == type9BeforeFirst);
        
        if (type0Doubled && typesUnchanged) {
            console.log("Vulnerability Exists: Unstake operations incorrectly moved funds to type0");
        } else {
            console.log("Vulnerability not Exist: Stake type accounting behaved correctly");
        }
    }
}