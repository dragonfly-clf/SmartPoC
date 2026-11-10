// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/etheraffle.sol";

contract EthraffleGasTest is Test {
    Ethraffle_v4b public raffle;
    address feeAddress = makeAddr("feeAddress");
    uint256 public constant TICKET_REFUNDS = 150; // Set to trigger gas concerns

    function setUp() public {
        vm.deal(feeAddress, 1000 ether);
        vm.prank(feeAddress);
        raffle = new Ethraffle_v4b();
    }

    function testRefundGasExceed() public {
        // Ensure contract is active
        if (raffle.paused()) raffle.togglePause();

        uint256 pricePerTicket = raffle.pricePerTicket();
        uint256 totalTickets = raffle.totalTickets();
        
        // Create users and buy tickets
        for (uint256 i = 1; i <= TICKET_REFUNDS; i++) {
            address user = address(uint160(5000 + i));
            vm.deal(user, pricePerTicket);
            vm.prank(user);
            raffle.buyTickets{value: pricePerTicket}();
        }

        // Request refunds from all users
        uint256 maxGasUsed;
        
        for (uint256 i = 1; i <= TICKET_REFUNDS; i++) {
            address user = address(uint160(5000 + i));
            vm.prank(user);
            
            uint256 startGas = gasleft();
            raffle.getRefund();
            uint256 gasUsed = startGas - gasleft();
            
            if (gasUsed > maxGasUsed) maxGasUsed = gasUsed;
        }

        emit log_named_uint("Max gas used for single refund", maxGasUsed);
        emit log_named_uint("Total system tickets", totalTickets);

        // Vulnerability verification based on gas threshold
        if (maxGasUsed <= 5000000) {
            console.log("Vulnerability not Exist: Refund operations completed within acceptable gas limits");
        } else {
            console.log("Vulnerability Exists: Refund gas consumption (%s) exceeds operational safety limits", maxGasUsed);
        }
    }
}