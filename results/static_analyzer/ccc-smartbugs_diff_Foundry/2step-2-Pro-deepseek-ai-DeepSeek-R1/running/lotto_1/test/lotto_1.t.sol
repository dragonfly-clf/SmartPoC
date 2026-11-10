// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/lotto.sol";

contract GasBurner {
    uint256 counter;
    
    constructor() payable {}
    
    receive() external payable {
        uint256 startGas = gasleft();
        // Execute expensive operation (consumes >2300 gas)
        for (uint256 i = 0; i < 300; i++) {
            counter++;
        }
        uint256 gasUsed = startGas - gasleft();
        require(gasUsed > 2300, "Gas consumption too low");
    }
}

contract LottoTest is Test {
    Lotto public lotto;
    GasBurner public gasBurner;

    function setUp() public {
        lotto = new Lotto();
        gasBurner = new GasBurner();
        
        // Fund Lotto contract with 10 ETH
        vm.deal(address(lotto), 10 ether);
    }

    function testWinnerPaidEventFiresOnFailedSend() public {
        // Setup winner details
        lotto.setWinner(address(gasBurner), 1 ether);
        
        console2.log("--- BEFORE-Trigger Balances ---");
        uint256 initialWinnerBalance = address(gasBurner).balance;
        uint256 initialLottoBalance = address(lotto).balance;
        console2.log("Lotto ETH balance:", initialLottoBalance);
        console2.log("Winner ETH balance:", initialWinnerBalance);

        console2.log("--- Trigger sendToWinner ---");
        // Record logs before operation
        vm.recordLogs();
        lotto.sendToWinner();
        
        console2.log("--- AFTER-Trigger Balances ---");
        uint256 finalWinnerBalance = address(gasBurner).balance;
        uint256 finalLottoBalance = address(lotto).balance;
        console2.log("Lotto ETH balance:", finalLottoBalance);
        console2.log("Winner ETH balance:", finalWinnerBalance);

        // Verify WinnerPaid event emission
        Vm.Log[] memory logs = vm.getRecordedLogs();
        bool eventFound = false;
        
        bytes32 winnerPaidHash = keccak256("WinnerPaid(address,uint256)");
        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].topics[0] == winnerPaidHash) {
                // Validate event parameters
                address paidWinner = address(uint160(uint256(logs[i].topics[1])));
                uint256 paidAmount = abi.decode(logs[i].data, (uint256));
                
                assertEq(paidWinner, address(gasBurner), "Winner mismatch");
                assertEq(paidAmount, 1 ether, "Amount mismatch");
                eventFound = true;
                break;
            }
        }

        // Vulnerability comparison
        bool balancesUnchanged = (finalLottoBalance == initialLottoBalance) && 
                                 (finalWinnerBalance == initialWinnerBalance);
        bool eventEmittedButNotPaid = eventFound && balancesUnchanged;
        
        console2.log("--- Vulnerability Verdict ---");
        console2.log("Event emitted:", eventFound ? "YES" : "NO");
        console2.log("ETH balances unchanged:", balancesUnchanged ? "YES" : "NO");
        console2.log("Vulnerable state:", eventEmittedButNotPaid ? "YES" : "NO");

        // Final vulnerability verdict
        if (eventEmittedButNotPaid) {
            console2.log("Vulnerability Exists: WinnerPaid event emitted without actual ETH transfer");
        } else {
            console2.log("Vulnerability not Exist: Either event not emitted or ETH transfer succeeded");
        }
    }
}