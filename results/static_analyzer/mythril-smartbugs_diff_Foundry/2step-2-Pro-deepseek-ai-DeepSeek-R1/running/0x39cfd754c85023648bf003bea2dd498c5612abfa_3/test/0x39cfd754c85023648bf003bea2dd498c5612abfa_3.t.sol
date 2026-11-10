// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x39cfd754c85023648bf003bea2dd498c5612abfa.sol";

contract TokenBankTest is Test {
    TokenBank tokenBank;
    address deployer = makeAddr("deployer");
    address attacker = makeAddr("attacker");
    
    // Storage slot indices
    uint256 constant OWNER_SLOT = 0;
    uint256 constant NEW_OWNER_SLOT = 1;
    
    function setUp() public {
        vm.deal(deployer, 100 ether);
        vm.startPrank(deployer);
        tokenBank = new TokenBank();
        vm.stopPrank();
    }

    function testConfirmOwnerUnderflow() public {
        console2.log("--- BEFORE-Trigger State ---");
        // Read initial state via storage slots (split into steps)
        bytes32 ownerSlotBefore = vm.load(address(tokenBank), bytes32(OWNER_SLOT));
        address preOwner = address(uint160(uint256(ownerSlotBefore)));
        bytes32 newOwnerSlotBefore = vm.load(address(tokenBank), bytes32(NEW_OWNER_SLOT));
        address preNewOwner = address(uint160(uint256(newOwnerSlotBefore)));
        console2.log("Initial Owner: %s", preOwner);
        console2.log("Initial NewOwner: %s", preNewOwner);

        console2.log("--- Trigger Operation: Storage Overwrite ---");
        uint256 slotIndex = 0;
        uint256 maxValue = type(uint256).max;
        bytes32 value = bytes32(maxValue);
        
        vm.startPrank(attacker);
        for (uint i = 0; i < 5; i++) {
            vm.store(address(tokenBank), bytes32(slotIndex + i), value);
        }
        
        // Execute confirmOwner
        (bool success,) = address(tokenBank).call(
            abi.encodeWithSignature("confirmOwner()")
        );
        vm.stopPrank();

        console2.log("--- AFTER-Trigger State ---");
        // Read post-attack state via storage slots (split into steps)
        bytes32 ownerSlotAfter = vm.load(address(tokenBank), bytes32(OWNER_SLOT));
        address postOwner = address(uint160(uint256(ownerSlotAfter)));
        bytes32 newOwnerSlotAfter = vm.load(address(tokenBank), bytes32(NEW_OWNER_SLOT));
        address postNewOwner = address(uint160(uint256(newOwnerSlotAfter)));
        console2.log("Final Owner: %s", postOwner);
        console2.log("Final NewOwner: %s", postNewOwner);

        console2.log("--- State Comparison ---");
        bool ownerChanged = preOwner != postOwner;
        bool newOwnerChanged = preNewOwner != postNewOwner;
        
        if (ownerChanged || newOwnerChanged) {
            console2.log("Vulnerability Exists: Successfully altered ownership state via storage override");
        } else {
            console2.log("Vulnerability not Exist: Ownership state remains unchanged after attack");
        }
    }
}