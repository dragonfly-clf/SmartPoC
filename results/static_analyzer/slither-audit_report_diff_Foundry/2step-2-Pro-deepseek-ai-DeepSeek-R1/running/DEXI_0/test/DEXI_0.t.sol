// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DEXI.sol";

contract RescueFundsTest is Test {
    DEXI dexi;
    MaliciousToken maliciousToken;
    address receiver;
    
    function setUp() public {
        // Deploy DEXI contract
        dexi = new DEXI();
        
        // Deploy malicious token contract
        maliciousToken = new MaliciousToken();
        
        // Set up receiver address
        receiver = address(0x123);
        
        // Fund DEXI contract with malicious tokens
        maliciousToken.setBalance(address(dexi), 1000);
    }
    
    function test_RescueFundsUncheckedTransfer() public {
        // Capture initial state
        uint256 dexiBalanceBefore = maliciousToken.balanceOf(address(dexi));
        uint256 receiverBalanceBefore = maliciousToken.balanceOf(receiver);
        
        console.log("--- BEFORE-Trigger RescueFunds ---");
        console.log("DEXI token balance before:", dexiBalanceBefore);
        console.log("Receiver token balance before:", receiverBalanceBefore);
        
        console.log("--- Trigger RescueFunds ---");
        // Execute vulnerable function
        dexi.rescueFunds(address(maliciousToken), receiver);
        
        // Capture post-execution state
        uint256 dexiBalanceAfter = maliciousToken.balanceOf(address(dexi));
        uint256 receiverBalanceAfter = maliciousToken.balanceOf(receiver);
        
        console.log("--- AFTER-Trigger RescueFunds ---");
        console.log("DEXI token balance after:", dexiBalanceAfter);
        console.log("Receiver token balance after:", receiverBalanceAfter);
        
        // Differential comparison
        bool balancesUnchanged = (dexiBalanceBefore == dexiBalanceAfter) && 
                                (receiverBalanceBefore == receiverBalanceAfter);
        
        if (balancesUnchanged) {
            console.log("Vulnerability Exists: Token balances unchanged but transfer should have failed and function should revert");
        } else {
            console.log("Vulnerability not Exist: Token balances changed unexpectedly");
        }
    }
}

contract MaliciousToken {
    mapping(address => uint256) public balanceOf;
    
    function setBalance(address account, uint256 amount) external {
        balanceOf[account] = amount;
    }
    
    function transfer(address, uint256) external returns (bool) {
        // Always fail transfer
        return false;
    }
}