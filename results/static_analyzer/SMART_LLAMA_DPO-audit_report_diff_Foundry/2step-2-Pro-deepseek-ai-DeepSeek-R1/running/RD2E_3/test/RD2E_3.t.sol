// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/RD2E.sol";

contract MockERC20 {
    mapping(address => uint256) public balanceOf;
    
    function transfer(address to, uint256 amount) external returns (bool) {
        balanceOf[to] += amount;
        return true;
    }

    function mint(address to, uint256 amount) external {
        balanceOf[to] = amount;
    }
}

contract RD2EEventTest is Test {
    RD2E public rd2e;
    MockERC20 public mockToken;
    address owner = address(0xa1);
    uint256 constant AMOUNT = 100 ether;
    bytes32 constant TRANSFER_SIGNATURE = keccak256("Transfer(address,address,uint256)");
    
    function setUp() public {
        vm.startPrank(owner);
        rd2e = new RD2E();
        mockToken = new MockERC20();
        mockToken.mint(address(rd2e), AMOUNT);
        vm.stopPrank();
    }

    // Remove view modifier since vm.getRecordedLogs modifies state
    function hasTransferEvent(address emitter) internal returns (bool) {
        Vm.Log[] memory logs = vm.getRecordedLogs();
        for (uint256 i; i < logs.length; i++) {
            if (logs[i].emitter == emitter && logs[i].topics[0] == TRANSFER_SIGNATURE) {
                return true;
            }
        }
        return false;
    }

    function testWithdrawalStuckERC20MissingEvent() public {
        vm.startPrank(owner);
        console.log("--- BEFORE-Trigger ---");
        console.log("No Transfer event recorded yet");

        console.log("--- Trigger: withdrawalStuck ERC20 ---");
        vm.recordLogs();
        rd2e.withdrawalStuck(address(mockToken), AMOUNT);
        
        console.log("--- AFTER-Trigger ---");
        bool eventFound = hasTransferEvent(address(rd2e));
        console.log(eventFound ? "STATUS: Transfer event FOUND" : "STATUS: Transfer event MISSING");

        // Final verdict
        if (eventFound) {
            console.log("Vulnerability not Exist: Transfer event was emitted as expected");
        } else {
            console.log("Vulnerability Exists: Missing Transfer event indicates vulnerability");
        }
        vm.stopPrank();
    }

    function testWithdrawalStuckETHMissingEvent() public {
        vm.startPrank(owner);
        console.log("--- BEFORE-Trigger ---");
        console.log("No Transfer event recorded yet");

        vm.deal(address(rd2e), AMOUNT);
        console.log("--- Trigger: withdrawalStuck ETH ---");
        vm.recordLogs();
        rd2e.withdrawalStuck(address(0), AMOUNT);
        
        console.log("--- AFTER-Trigger ---");
        bool eventFound = hasTransferEvent(address(rd2e));
        console.log(eventFound ? "STATUS: Transfer event FOUND" : "STATUS: Transfer event MISSING");

        if (eventFound) {
            console.log("Vulnerability not Exist: Transfer event was emitted as expected");
        } else {
            console.log("Vulnerability Exists: Missing Transfer event indicates vulnerability");
        }
        vm.stopPrank();
    }

    function testWithdrawalStuckMaxERC20MissingEvent() public {
        vm.startPrank(owner);
        console.log("--- BEFORE-Trigger ---");
        console.log("No Transfer event recorded yet");

        console.log("--- Trigger: withdrawalStuckMax ERC20 ---");
        vm.recordLogs();
        rd2e.withdrawalStuckMax(address(mockToken));
        
        console.log("--- AFTER-Trigger ---");
        bool eventFound = hasTransferEvent(address(rd2e));
        console.log(eventFound ? "STATUS: Transfer event FOUND" : "STATUS: Transfer event MISSING");

        if (eventFound) {
            console.log("Vulnerability not Exist: Transfer event was emitted as expected");
        } else {
            console.log("Vulnerability Exists: Missing Transfer event indicates vulnerability");
        }
        vm.stopPrank();
    }

    function testWithdrawalStuckMaxETHMissingEvent() public {
        vm.startPrank(owner);
        console.log("--- BEFORE-Trigger ---");
        console.log("No Transfer event recorded yet");

        vm.deal(address(rd2e), AMOUNT);
        console.log("--- Trigger: withdrawalStuckMax ETH ---");
        vm.recordLogs();
        rd2e.withdrawalStuckMax(address(0));
        
        console.log("--- AFTER-Trigger ---");
        bool eventFound = hasTransferEvent(address(rd2e));
        console.log(eventFound ? "STATUS: Transfer event FOUND" : "STATUS: Transfer event MISSING");

        if (eventFound) {
            console.log("Vulnerability not Exist: Transfer event was emitted as expected");
        } else {
            console.log("Vulnerability Exists: Missing Transfer event indicates vulnerability");
        }
        vm.stopPrank();
    }
}