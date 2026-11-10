// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x524960d55174d912768678d8c606b4d50b79d7b1.sol";

contract Centra4TransferTest is Test {
    Centra4 public centra;
    address public constant CONTRACT_ADDRESS = 0x96A65609a7B84E8842732DEB08f56C3E21aC6f8a;
    address public constant TRANSFER_TO = 0xAa27f8C1160886aacba64B2319D8d5469ef2Af79;
    address testUser = makeAddr("testUser");

    function setUp() public {
        centra = new Centra4();
    }

    function testTransferRevertIncrementsCounters() public {
        vm.startPrank(testUser);

        // Mock both external calls - first succeeds, second reverts
        vm.mockCall(
            CONTRACT_ADDRESS,
            abi.encodeWithSignature("register(string)", "CentraToken"),
            ""
        );
        vm.mockCallRevert(
            CONTRACT_ADDRESS,
            abi.encodeWithSignature("transfer(address,uint256)", TRANSFER_TO, 1),
            abi.encode("Transfer failed")
        );

        // Query initial state using the methods from differential description
        uint256 globalTransfersBefore = centra.totalTransfers();
        uint256 userTransfersBefore = centra.userTransferCounts(testUser);
        
        console2.log("--- BEFORE-Trigger Transfer ---");
        console2.log("Global Transfers Count (before):", globalTransfersBefore);
        console2.log("User Transfers Count (before):", userTransfersBefore);

        console2.log("--- Trigger Transfer ---");
        bool result = centra.transfer();

        console2.log("--- AFTER-Trigger Transfer ---");
        uint256 globalTransfersAfter = centra.totalTransfers();
        uint256 userTransfersAfter = centra.userTransferCounts(testUser);
        console2.log("Global Transfers Count (after):", globalTransfersAfter);
        console2.log("User Transfers Count (after):", userTransfersAfter);

        // Verify transfer failure
        assertFalse(result, "Transfer should have failed but succeeded");
        
        // Differential comparison logic
        bool bothCountersIncreased = 
            (userTransfersAfter == userTransfersBefore + 1) && 
            (globalTransfersAfter == globalTransfersBefore + 1);
        
        if (bothCountersIncreased) {
            console2.log("[Verdict] Both counters increased despite transfer failure - vulnerability confirmed");
            console2.log("Vulnerability Exists: Transfer counters increment even on failed transfers");
        } else {
            console2.log("[Verdict] Counters unchanged or improperly modified - vulnerability not detected");
            console2.log("Vulnerability not Exist: Failed transfers do not increment transfer counters");
        }
        
        vm.stopPrank();
    }
}