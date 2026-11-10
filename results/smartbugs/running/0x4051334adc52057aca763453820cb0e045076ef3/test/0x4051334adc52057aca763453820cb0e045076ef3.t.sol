// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4051334adc52057aca763453820cb0e045076ef3.sol";

contract MockToken {
    bool public shouldFail;

    function setShouldFail(bool _shouldFail) public {
        shouldFail = _shouldFail;
    }

    function transferFrom(address, address, uint256) public returns (bool) {
        return !shouldFail;
    }
}

contract AirdropTest is Test {
    airdrop public airdropContract;
    MockToken public mockToken;
    address owner = address(1);
    address recipient1 = address(2);
    address recipient2 = address(3);
    
    struct ContractState {
        uint256 tokens1;
        uint256 tokens2;
        uint256 airdrops;
        uint256 tokensDistributed;
        uint256 ownerCount;
    }
    
    function captureState() internal view returns (ContractState memory state) {
        (, state.tokens1) = airdropContract.getUserStats(recipient1);
        (, state.tokens2) = airdropContract.getUserStats(recipient2);
        state.airdrops = airdropContract.totalAirdrops();
        state.tokensDistributed = airdropContract.totalTokensDistributed();
        state.ownerCount = airdropContract.userAirdropCount(owner);
    }
    
    function logState(string memory label, ContractState memory state) internal {
        console.log(label);
        console.log("Recipient1 tokensReceived:", state.tokens1);
        console.log("Recipient2 tokensReceived:", state.tokens2);
        console.log("Total Airdrops:", state.airdrops);
        console.log("Total Tokens Distributed:", state.tokensDistributed);
        console.log("Owner Airdrop Count:", state.ownerCount);
        console.log("--------------");
    }

    function setUp() public {
        vm.startPrank(owner);
        airdropContract = new airdrop();
        mockToken = new MockToken();
        vm.stopPrank();
    }

    function testUncheckedLowLevelCall() public {
        address[] memory recipients = new address[](2);
        recipients[0] = recipient1;
        recipients[1] = recipient2;
        uint256 amount = 100;

        // First test with successful transfers (baseline)
        vm.prank(owner);
        bool success = airdropContract.transfer(owner, address(mockToken), recipients, amount);
        assertTrue(success);

        // Make transfers fail
        mockToken.setShouldFail(true);
        
        // Capture state before failing transfer
        ContractState memory pre = captureState();
        logState("--- BEFORE Failing Transfer ---", pre);

        // Execute transfer with failing calls
        console.log("--- TRIGGER: Execute Failing Transfer! ---");
        vm.prank(owner);
        success = airdropContract.transfer(owner, address(mockToken), recipients, amount);
        assertTrue(success); // Function still returns true despite failed transfers

        // Capture state after failing transfer
        ContractState memory post = captureState();
        logState("--- AFTER Failing Transfer ---", post);

        // Differential comparison
        console.log("--- DIFFERENTIAL RESULTS ---");
        bool tokens1Changed = pre.tokens1 != post.tokens1;
        bool tokens2Changed = pre.tokens2 != post.tokens2;
        bool airdropsChanged = pre.airdrops != post.airdrops;
        bool distributedChanged = pre.tokensDistributed != post.tokensDistributed;
        bool ownerCountChanged = pre.ownerCount != post.ownerCount;
        bool vulnerabilityTriggered = tokens1Changed || tokens2Changed || airdropsChanged || distributedChanged || ownerCountChanged;

        console.log("Recipient1 tokens changed:", tokens1Changed ? "YES" : "NO");
        console.log("Recipient2 tokens changed:", tokens2Changed ? "YES" : "NO");
        console.log("Total Airdrops changed:", airdropsChanged ? "YES" : "NO");
        console.log("Total Distributed changed:", distributedChanged ? "YES" : "NO");
        console.log("Owner Count changed:", ownerCountChanged ? "YES" : "NO");

        if (vulnerabilityTriggered) {
            console.log("Vulnerability Exists: State modified despite failed token transfers");
        } else {
            console.log("Vulnerability not Exist: State remained unchanged after failing transfers");
        }
    }
}