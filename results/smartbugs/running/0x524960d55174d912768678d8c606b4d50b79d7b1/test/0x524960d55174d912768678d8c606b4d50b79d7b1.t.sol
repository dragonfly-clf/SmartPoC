// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x524960d55174d912768678d8c606b4d50b79d7b1.sol";

contract Centra4Test is Test {
    Centra4 centra;
    address owner = address(0x1);
    address attacker = address(0x2);
    
    // Mock contract that will fail when called
    address failingContract;

    function setUp() public {
        vm.startPrank(owner);
        centra = new Centra4();
        failingContract = address(new FailingContract());
        vm.stopPrank();
    }

    function testUncheckedLowLevelCall() public {
        // --- BEFORE: Record initial state ---
        console.log("--- BEFORE-Trigger Transfer ---");
        (uint256 initialUserTransfers, uint256 initialGlobalTransfers) = centra.getTransferStats(attacker);
        console.log("[PRE] Attacker transfer count:", initialUserTransfers);
        console.log("[PRE] Global transfer count:", initialGlobalTransfers);

        // --- TRIGGER: Perform attacking action ---
        console.log("--- Trigger Transfer ---");
        vm.prank(attacker);
        // Override the hardcoded contract address to point to our failing mock
        vm.etch(0x96A65609a7B84E8842732DEB08f56C3E21aC6f8a, failingContract.code);
        (bool success,) = address(centra).call(abi.encodeWithSignature("transfer()"));
        console.log("Call result:", success ? "SUCCESS" : "FAILURE");

        // --- AFTER: Record updated state ---
        console.log("--- AFTER-Trigger Transfer ---");
        (uint256 updatedUserTransfers, uint256 updatedGlobalTransfers) = centra.getTransferStats(attacker);
        console.log("[POST] Attacker transfer count:", updatedUserTransfers);
        console.log("[POST] Global transfer count:", updatedGlobalTransfers);

        // --- VALIDATION: Check state changes ---
        console.log("--- Result Validation ---");
        bool userTransfersIncreased = updatedUserTransfers == initialUserTransfers + 1;
        bool globalTransfersIncreased = updatedGlobalTransfers == initialGlobalTransfers + 1;
        console.log("User transfers increased after failure:", userTransfersIncreased);
        console.log("Global transfers increased after failure:", globalTransfersIncreased);

        // --- VULNERABILITY VERDICT ---
        if (!success && (userTransfersIncreased || globalTransfersIncreased)) {
            console.log("Vulnerability Exists: State was updated despite low-level call failure");
        } else if (!success && !userTransfersIncreased && !globalTransfersIncreased) {
            console.log("Vulnerability not Exist: State remains unchanged after call failure");
        } else {
            console.log("Test inconclusive: Unexpected results");
        }
    }
}

contract FailingContract {
    // This contract will fail all calls to it
    fallback() external payable {
        revert("Intentional failure");
    }
}