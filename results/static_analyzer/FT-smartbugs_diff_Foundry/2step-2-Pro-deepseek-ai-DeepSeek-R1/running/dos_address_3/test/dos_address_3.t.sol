// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/dos_address.sol";

contract DosGasTest is Test {
    DosGas public dosGas;
    address testUser = address(0x123);

    function setUp() public {
        dosGas = new DosGas();
    }

    function test_addCreditorsHighGasUsage() public {
        console2.log("--- BEFORE-Trigger Gas Snapshot ---");
        uint gasStart = gasleft();
        console2.log("Starting gas available: %s", gasStart);

        console2.log("--- Trigger: addCreditors() call ---");
        dosGas.addCreditors();

        console2.log("--- AFTER-Trigger Gas Snapshot ---");
        uint gasUsed = gasStart - gasleft();
        console2.log("Gas consumed: %s", gasUsed);

        if (gasUsed > 1_000_000) {
            console2.log("Vulnerability Exists: Function consumes %s gas (exceeds 1M limit), leading to DoS risk", gasUsed);
        } else {
            console2.log("Vulnerability not Exist: Function consumes %s gas (below 1M threshold)", gasUsed);
        }
    }
}