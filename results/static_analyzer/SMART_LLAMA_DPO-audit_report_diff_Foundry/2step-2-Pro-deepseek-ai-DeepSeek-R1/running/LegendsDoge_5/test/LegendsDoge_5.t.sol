// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LegendsDoge.sol";

contract MaliciousCharity {
    bool public called;
    LegendsDoge token;
    
    constructor(LegendsDoge _token) {
        token = _token;
    }
}

contract LegendsDogeTest is Test {
    LegendsDoge token;
    MaliciousCharity maliciousCharity;
    address owner = address(0x1);
    address user = address(0x2);
    uint256 initialSupply = 1000 ether;

    // State struct to reduce variable count
    struct TokenState {
        uint256 userBalance;
        uint256 receiverBalance;
        uint256 totalSupply;
        uint256 charityBalance;
        bool called;
    }

    function setUp() public {
        vm.startPrank(owner);
        token = new LegendsDoge(
            "LegendsDoge",
            "LDOGE",
            18,
            initialSupply,
            1, // txFee (1%)
            1, // burnFee (1%)
            1, // charityFee (1%)
            address(0), // Temp charity address
            owner
        );
        vm.stopPrank();

        maliciousCharity = new MaliciousCharity(token);
        
        vm.prank(owner);
        token.setAsCharityAccount(address(maliciousCharity));

        vm.prank(owner);
        token.transfer(user, 100 ether);
    }

    function _getTokenState(
        address user_addr,
        address receiver_addr
    ) internal view returns (TokenState memory) {
        return TokenState({
            userBalance: token.balanceOf(user_addr),
            receiverBalance: token.balanceOf(receiver_addr),
            totalSupply: token.totalSupply(),
            charityBalance: token.balanceOf(address(maliciousCharity)),
            called: maliciousCharity.called()
        });
    }

    function testNoReentrancy() public {
        address receiver = address(0x3);
        uint256 amount = 10 ether;

        console.log("--- BEFORE-Trigger state ---");
        TokenState memory before = _getTokenState(user, receiver);
        _logState(before);

        console.log("--- Trigger Transfer ---");
        vm.prank(user);
        token.transfer(receiver, amount);
        
        console.log("--- AFTER-Trigger state ---");
        TokenState memory afterState = _getTokenState(user, receiver);
        _logState(afterState);
        
        console.log("--- State Changes Analysis ---");
        bool anomalyDetected = _checkAnomalies(before, afterState, amount);
        
        if (anomalyDetected) {
            console.log("\nVulnerability Exists: Reentrancy or state corruption detected");
        } else {
            console.log("\nVulnerability not Exist: No state anomalies detected");
        }
    }

    function _logState(TokenState memory s) internal view {
        console.log("User (%s) balance:    %s", user, s.userBalance);
        console.log("Receiver (%s) balance: %s", address(0x3), s.receiverBalance);
        console.log("Charity (%s) balance: %s", address(maliciousCharity), s.charityBalance);
        console.log("Total supply:         %s", s.totalSupply);
        console.log("Called flag:          %s", s.called);
        console.log("");
    }

    function _checkAnomalies(
        TokenState memory before,
        TokenState memory afterState,
        uint256 amount
    ) internal returns (bool anomalyDetected) {
        uint256 expectedUserLoss = amount;
        uint256 expectedReceiverGain = amount * 97 / 100;
        uint256 expectedCharityGain = amount * 1 / 100;
        uint256 expectedSupplyBurn = amount * 1 / 100;

        uint256 actualUserLoss = before.userBalance - afterState.userBalance;
        uint256 actualReceiverGain = afterState.receiverBalance - before.receiverBalance;
        uint256 actualCharityGain = afterState.charityBalance - before.charityBalance;
        uint256 actualSupplyBurn = before.totalSupply - afterState.totalSupply;

        console.log("User loss:                 %s (expected: %s)", 
            actualUserLoss, 
            expectedUserLoss
        );
        console.log("Receiver gain:             %s (expected: %s)", 
            actualReceiverGain, 
            expectedReceiverGain
        );
        console.log("Charity gain:              %s (expected: %s)", 
            actualCharityGain, 
            expectedCharityGain
        );
        console.log("Supply reduction:          %s (expected: %s)", 
            actualSupplyBurn, 
            expectedSupplyBurn
        );
        console.log("Called flag changed:       %s", 
            afterState.called != before.called ? "YES" : "NO"
        );
        console.log("");

        anomalyDetected = false;
        if (afterState.called) {
            console.log("!!! CRITICAL: Reentrancy detected !!!");
            anomalyDetected = true;
        }
        if (actualUserLoss != expectedUserLoss) {
            console.log("!!! Anomaly: User lost %s, expected %s !!!", 
                actualUserLoss, expectedUserLoss);
            anomalyDetected = true;
        }
        if (actualReceiverGain != expectedReceiverGain) {
            console.log("!!! Anomaly: Receiver gained %s, expected %s !!!", 
                actualReceiverGain, expectedReceiverGain);
            anomalyDetected = true;
        }
        if (actualCharityGain != expectedCharityGain) {
            console.log("!!! Anomaly: Charity gained %s, expected %s !!!", 
                actualCharityGain, expectedCharityGain);
            anomalyDetected = true;
        }
        if (actualSupplyBurn != expectedSupplyBurn) {
            console.log("!!! Anomaly: Supply reduced by %s, expected %s !!!", 
                actualSupplyBurn, expectedSupplyBurn);
            anomalyDetected = true;
        }

        return anomalyDetected;
    }
}