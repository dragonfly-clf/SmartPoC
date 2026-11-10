// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xa1fceeff3acc57d257b917e30c4df661401d6431.sol";

contract MockToken {
    bool public shouldFail;

    constructor(bool _shouldFail) {
        shouldFail = _shouldFail;
    }

    function transferFrom(address, address, uint256) external returns (bool) {
        return !shouldFail;
    }
}

contract AirDropContractTest is Test {
    AirDropContract airDrop;
    MockToken failingToken;
    MockToken workingToken;
    address user = address(0x1);
    address[] recipients;
    uint256[] amounts;

    function setUp() public {
        airDrop = new AirDropContract();
        failingToken = new MockToken(true);
        workingToken = new MockToken(false);
        
        // Setup test data
        recipients.push(address(0x2));
        recipients.push(address(0x3));
        amounts.push(100);
        amounts.push(200);
    }

    function testUncheckedLowLevelCall() public {
        // Record initial state
        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 initialTotalAirdrops = airDrop.totalAirdrops();
        uint256 initialTotalTokens = airDrop.totalTokensDistributed();
        (uint256 initialCount0, uint256 initialTokens0) = airDrop.getUserStats(recipients[0]);
        (uint256 initialCount1, uint256 initialTokens1) = airDrop.getUserStats(recipients[1]);
        
        console.log("Initial Total Airdrops: %s", initialTotalAirdrops);
        console.log("Initial Total Tokens: %s", initialTotalTokens);
        console.log("Recipient0: InitialCount=%s, InitialTokens=%s", initialCount0, initialTokens0);
        console.log("Recipient1: InitialCount=%s, InitialTokens=%s", initialCount1, initialTokens1);
        
        console.log("--- Trigger Transfer (failing token) ---");
        // Execute transfer with failing token
        vm.prank(user);
        airDrop.transfer(address(failingToken), recipients, amounts);

        // Record post-trigger state
        console.log("--- AFTER-Trigger Transfer ---");
        uint256 finalTotalAirdrops = airDrop.totalAirdrops();
        uint256 finalTotalTokens = airDrop.totalTokensDistributed();
        (uint256 finalCount0, uint256 finalTokens0) = airDrop.getUserStats(recipients[0]);
        (uint256 finalCount1, uint256 finalTokens1) = airDrop.getUserStats(recipients[1]);
        
        console.log("Final Total Airdrops: %s", finalTotalAirdrops);
        console.log("Final Total Tokens: %s", finalTotalTokens);
        console.log("Recipient0: FinalCount=%s, FinalTokens=%s", finalCount0, finalTokens0);
        console.log("Recipient1: FinalCount=%s, FinalTokens=%s", finalCount1, finalTokens1);
        
        // Differential verification
        bool totalAirdropsIncreased = finalTotalAirdrops > initialTotalAirdrops;
        bool totalTokensIncreased = finalTotalTokens > initialTotalTokens;
        bool recipientStatsChanged = (finalCount0 > initialCount0) || 
                                     (finalTokens0 > initialTokens0) ||
                                     (finalCount1 > initialCount1) || 
                                     (finalTokens1 > initialTokens1);
        
        bool vulnerabilityExists = totalAirdropsIncreased || totalTokensIncreased || recipientStatsChanged;
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: State was incorrectly updated despite failed token transfers");
        } else {
            console.log("Vulnerability not Exist: State remained unchanged as expected");
        }
    }

    function testWorkingTransfer() public {
        // Execute transfer with working token
        vm.prank(user);
        airDrop.transfer(address(workingToken),recipients, amounts);
    }
}