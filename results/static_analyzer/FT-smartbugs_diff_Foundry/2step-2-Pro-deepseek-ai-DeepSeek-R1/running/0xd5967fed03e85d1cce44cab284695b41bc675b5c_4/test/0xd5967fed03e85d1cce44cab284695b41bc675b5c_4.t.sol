// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xd5967fed03e85d1cce44cab284695b41bc675b5c.sol";

contract DemoTest is Test {
    demo public myDemo;
    address constant FROM = address(1);
    address constant RECIPIENT = address(2);
    address constant NON_CONTRACT = address(0xDEAD);

    function setUp() public {
        myDemo = new demo();
    }

    // Test state update after call to zero address fails
    function test_TransferWithZeroAddressUpdatesState() public {
        address[] memory recipients = new address[](1);
        recipients[0] = RECIPIENT;
        uint amount = 100 ether;

        // Get initial state
        (uint initialTotal, uint initialUser) = _getInitialState(recipients[0]);

        console.log("--- BEFORE-Trigger State ---");
        console.log("totalTransfers for recipient:", initialTotal);
        console.log("userTransfers from FROM to recipient:", initialUser);

        console.log("--- Trigger Transfer ---");
        // Call should not revert since failed calls are ignored in contract
        myDemo.transfer(FROM, address(0), recipients, amount);

        console.log("--- AFTER-Trigger State ---");
        uint finalTotal = myDemo.totalTransfers(recipients[0]);
        uint finalUser = myDemo.userTransfers(FROM, recipients[0]);
        console.log("totalTransfers for recipient:", finalTotal);
        console.log("userTransfers from FROM to recipient:", finalUser);

        // Check if state changed
        bool stateChanged = (finalTotal != initialTotal) || (finalUser != initialUser);
        console.log("State changed:", stateChanged ? "YES" : "NO");
        
        // Vulnerability exists if state changed despite failed call
        if(stateChanged) {
            console.log("Vulnerability Exists: State updated despite external call failing to zero address");
        } else {
            console.log("Vulnerability not Exist: State unchanged as expected");
        }
    }

    // Test state update after call to non-contract address fails
    function test_TransferWithNonContractAddressUpdatesState() public {
        address[] memory recipients = new address[](1);
        recipients[0] = RECIPIENT;
        uint amount = 100 ether;

        // Get initial state
        (uint initialTotal, uint initialUser) = _getInitialState(recipients[0]);

        console.log("--- BEFORE-Trigger State ---");
        console.log("totalTransfers for recipient:", initialTotal);
        console.log("userTransfers from FROM to recipient:", initialUser);

        // NON_CONTRACT address has no bytecode
        assertEq(NON_CONTRACT.code.length, 0, "Not a non-contract address");
        
        console.log("--- Trigger Transfer ---");
        myDemo.transfer(FROM, NON_CONTRACT, recipients, amount);

        console.log("--- AFTER-Trigger State ---");
        uint finalTotal = myDemo.totalTransfers(recipients[0]);
        uint finalUser = myDemo.userTransfers(FROM, recipients[0]);
        console.log("totalTransfers for recipient:", finalTotal);
        console.log("userTransfers from FROM to recipient:", finalUser);

        // Check if state changed
        bool stateChanged = (finalTotal != initialTotal) || (finalUser != initialUser);
        console.log("State changed:", stateChanged ? "YES" : "NO");
        
        // Vulnerability exists if state changed despite failed call
        if(stateChanged) {
            console.log("Vulnerability Exists: State updated despite external call failing to non-contract address");
        } else {
            console.log("Vulnerability not Exist: State unchanged as expected");
        }
    }

    // Helper to fetch initial state values
    function _getInitialState(address recipient) 
        private 
        view 
        returns (uint initialTotal, uint initialUser) 
    {
        initialTotal = myDemo.totalTransfers(recipient);
        initialUser = myDemo.userTransfers(FROM, recipient);
    }
}