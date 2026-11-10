// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ApocalypseLand.sol";

contract ApocalypseLandEventTest is Test {
    ApocalypseLand token;
    address owner = address(0x123);
    address user = address(0x456);
    address referrer = address(0x789);
    
    // Event signatures
    bytes32 constant TRANSFER_EVENT = 
        keccak256("Transfer(address,address,uint256)");

    function setUp() public {
        vm.startPrank(owner);
        token = new ApocalypseLand();
        token.setAuth(owner, owner);  // Authorize owner for authNum calls
        vm.stopPrank();
    }

    function enableSale() internal {
        vm.startPrank(owner);
        token.authNum(1);
        token.set(4, 1);    // Enable sale (tag 4)
        token.authNum(1);
        token.set(9, block.number + 1000); // Set future block (tag 9)
        token.authNum(1);
        token.set(10, 1000); // Set price: 1000 tokens/ETH (tag 10)
        token.authNum(1);
        token.set(5, 1000); // Set referEth: 10% (1000 = 10.00%)
        token.authNum(1);
        token.set(6, 1000); // Set referToken: 10% (1000 = 10.00%)
        vm.stopPrank();
    }

    function testClearETHMissingTransferEvent() public {
        // Prepare contract with ETH balance
        vm.deal(address(token), 1 ether);
        vm.prank(owner);
        token.authNum(1000); // Set required auth for clearETH

        // Record logs and execute clearETH
        console.log("--- Trigger clearETH ---");
        vm.recordLogs();
        vm.prank(owner);
        token.clearETH();
        Vm.Log[] memory entries = vm.getRecordedLogs();

        // Scan logs for Transfer events
        bool foundEvent;
        for (uint i; i < entries.length; i++) {
            if (entries[i].topics[0] == TRANSFER_EVENT) {
                foundEvent = true;
                break;
            }
        }
        
        console.log("--- Event Check ---");
        if (foundEvent) {
            console.log("Vulnerability Exists: Unexpected Transfer event found in clearETH");
        } else {
            console.log("Vulnerability not Exist: No Transfer event found in clearETH");
        }
    }

    function testSetMissingTransferEvent() public {
        vm.prank(owner);
        token.authNum(1); // Set required auth for set

        // Record logs 
        console.log("--- Trigger set ---");
        vm.recordLogs();
        vm.prank(owner);
        token.set(7, 0.1 ether); // Set airdropEth to 0.1 ETH (tag 7)
        Vm.Log[] memory entries = vm.getRecordedLogs();

        // Scan logs for Transfer events
        bool foundEvent;
        for (uint i; i < entries.length; i++) {
            if (entries[i].topics[0] == TRANSFER_EVENT) {
                foundEvent = true;
                break;
            }
        }
        
        console.log("--- Event Check ---");
        if (foundEvent) {
            console.log("Vulnerability Exists: Unexpected Transfer event found in set");
        } else {
            console.log("Vulnerability not Exist: No Transfer event found in set");
        }
    }

    function testBuyMissingTransferEvent() public {
        // Enable and configure sale
        enableSale();
        
        // Setup accounts with ETH
        uint256 userAmt = 0.01 ether;
        vm.deal(user, userAmt);
        vm.deal(referrer, userAmt);

        // Prepare referrer 
        vm.prank(referrer);
        token.buy{value: userAmt}(address(0));

        // Record logs 
        console.log("--- Trigger buy ---");
        vm.recordLogs();
        vm.prank(user);
        token.buy{value: userAmt}(referrer);
        Vm.Log[] memory entries = vm.getRecordedLogs();

        // Scan logs for specific ETH deposit event
        bool foundEvent;
        bytes32 userTopic = bytes32(uint256(uint160(user)));
        bytes32 contractTopic = bytes32(uint256(uint160(address(token))));
        
        for (uint i; i < entries.length; i++) {
            if (
                entries[i].topics[0] == TRANSFER_EVENT &&
                entries[i].topics[1] == userTopic &&
                entries[i].topics[2] == contractTopic
            ) {
                uint256 value = abi.decode(entries[i].data, (uint256));
                if (value == userAmt) {
                    foundEvent = true;
                    break;
                }
            }
        }
        
        console.log("--- Event Check ---");
        if (foundEvent) {
            console.log("Vulnerability Exists: Transfer event found for ETH deposit in buy()");
        } else {
            console.log("Vulnerability not Exist: No Transfer event found for ETH deposit in buy()");
        }
    }
}