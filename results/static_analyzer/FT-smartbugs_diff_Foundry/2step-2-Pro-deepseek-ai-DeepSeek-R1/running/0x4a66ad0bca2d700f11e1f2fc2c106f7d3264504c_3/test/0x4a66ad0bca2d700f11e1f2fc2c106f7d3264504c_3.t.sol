// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4a66ad0bca2d700f11e1f2fc2c106f7d3264504c.sol";

contract MaliciousToken {
    EBU public victim;
    uint256 public recordedBalance;
    
    constructor(EBU _victim) {
        victim = _victim;
    }

    function transferFrom(address, address _to, uint256) external returns (bool) {
        recordedBalance = victim.getRecipientBalance(_to);
        return true;
    }
}

contract EBUReentrancyTest is Test {
    EBU public ebu;
    MaliciousToken public maliciousToken;
    
    // Privileged address required for transfer
    address constant PRIVILEGED_ADDRESS = 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9;
    
    function setUp() public {
        // Deploy contracts
        ebu = new EBU();
        maliciousToken = new MaliciousToken(ebu);
        
        // Verify and set storage slots (caddress at slot0, from at slot1)
        bytes32 caddressSlot = bytes32(uint256(0));
        bytes32 fromSlot = bytes32(uint256(1));
        
        // Set caddress to maliciousToken address
        bytes32 caddressValue = bytes32(uint256(uint160(address(maliciousToken))));
        vm.store(address(ebu), caddressSlot, caddressValue);
        
        // Set from to PRIVILEGED_ADDRESS
        bytes32 fromValue = bytes32(uint256(uint160(PRIVILEGED_ADDRESS)));
        vm.store(address(ebu), fromSlot, fromValue);
    }

    function verifySlotContents() private view {
        // Load caddress from slot0
        bytes32 caddressValue = vm.load(address(ebu), bytes32(uint256(0)));
        assertEq(address(uint160(uint256(caddressValue))), address(maliciousToken), "Incorrect caddress storage");
        
        // Load from address from slot1
        bytes32 fromValue = vm.load(address(ebu), bytes32(uint256(1)));
        assertEq(address(uint160(uint256(fromValue))), PRIVILEGED_ADDRESS, "Incorrect from storage");
    }

    function test_recipientBalanceNotUpdatedDuringExternalCall() public {
        // Verify storage setup
        verifySlotContents();
        
        // Create test parameters
        address attacker = address(0x123);
        uint256 transferAmount = 10;
        uint256 scaledAmount = transferAmount * 1e18;
        
        // Setup recipient array
        address[] memory recipients = new address[](1);
        recipients[0] = attacker;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = transferAmount;
        
        // BEFORE: Record initial state
        console2.log("--- BEFORE Trigger ---");
        uint256 initialBalance = ebu.getRecipientBalance(attacker);
        console2.log("Initial recipient balance: %s", initialBalance);
        (uint256 initialTotalTransfers, uint256 initialTotalAmount) = ebu.getTotalStats();
        console2.log("Initial total transfers: %s, total amount: %s", initialTotalTransfers, initialTotalAmount);

        // Execute transfer as privileged address
        console2.log("--- Trigger: transfer (includes external call) ---");
        vm.prank(PRIVILEGED_ADDRESS);
        ebu.transfer(recipients, amounts);
        
        // AFTER: Capture final state
        console2.log("--- AFTER Trigger ---");
        uint256 finalRecipientBalance = ebu.getRecipientBalance(attacker);
        console2.log("Final recipient balance: %s", finalRecipientBalance);
        (uint256 finalTotalTransfers, uint256 finalTotalAmount) = ebu.getTotalStats();
        console2.log("Final total transfers: %s, total amount: %s", finalTotalTransfers, finalTotalAmount);
        
        // Verify captured state during external call
        uint256 capturedBalance = maliciousToken.recordedBalance(); // Corrected getter function call
        console2.log("Captured state during external call: %s", capturedBalance);
        
        // Differential validation
        console2.log("--- Differential Validation ---");
        bool vulnerabilityExists = (capturedBalance == initialBalance);
        console2.log("Condition - capturedBalance == initialBalance? : %s", vulnerabilityExists);
        console2.log("Final state updated correctly? : %s", 
            (finalTotalTransfers == initialTotalTransfers + 1) &&
            (finalTotalAmount == initialTotalAmount + scaledAmount) &&
            (finalRecipientBalance == initialBalance + scaledAmount)
        );
        
        // Vulnerability verdict - Single final line as required
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: State was incorrectly updated during external call");
        } else {
            console2.log("Vulnerability not Exist: State updated correctly during external call");
        }
    }
}