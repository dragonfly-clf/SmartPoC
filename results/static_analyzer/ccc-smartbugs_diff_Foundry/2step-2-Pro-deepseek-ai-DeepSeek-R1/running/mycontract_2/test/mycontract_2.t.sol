// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/mycontract.sol";

contract ContractOwner {
    MyContract public myContract;
    
    constructor() {
        myContract = new MyContract();
    }
    
    function callSendTo(address receiver, uint amount) public {
        myContract.sendTo(receiver, amount);
    }
}

contract AuditTest is Test {
    MyContract public myContract;
    ContractOwner public contractOwner;
    address receiver = makeAddr("receiver");
    
    function setUp() public {
        // Deploy contracts
        contractOwner = new ContractOwner();
        myContract = contractOwner.myContract();
        
        // Fund contract for transfers
        vm.deal(address(myContract), 1 ether);
    }
    
    function test_DenialOfServiceWhenOwnerIsContract() public {
        // Record state BEFORE attack
        uint256 receiverBalanceBefore = receiver.balance;
        uint256 contractBalanceBefore = address(myContract).balance;
        uint256 totalTransfersBefore = myContract.totalTransfers();
        uint256 recipientBalanceBefore = myContract.recipientBalances(receiver);

        console.log("--- BEFORE-Trigger State ---");
        console.log("receiver.balance: ", receiverBalanceBefore);
        console.log("contract.balance: ", contractBalanceBefore);
        console.log("totalTransfers: ", totalTransfersBefore);
        console.log("recipientBalances(receiver): ", recipientBalanceBefore);

        // Attempt to call sendTo() through contract owner (should fail)
        console.log("--- Trigger SendTo ---");
        vm.expectRevert();
        contractOwner.callSendTo(receiver, 1 ether);
        console.log("Call to sendTo reverted as expected");

        // Record state AFTER attack
        uint256 receiverBalanceAfter = receiver.balance;
        uint256 contractBalanceAfter = address(myContract).balance;
        uint256 totalTransfersAfter = myContract.totalTransfers();
        uint256 recipientBalanceAfter = myContract.recipientBalances(receiver);

        console.log("--- AFTER-Trigger State ---");
        console.log("receiver.balance: ", receiverBalanceAfter);
        console.log("contract.balance: ", contractBalanceAfter);
        console.log("totalTransfers: ", totalTransfersAfter);
        console.log("recipientBalances(receiver): ", recipientBalanceAfter);

        // Validate state unchanged
        bool stateUnchanged = (receiverBalanceAfter == receiverBalanceBefore) &&
                             (contractBalanceAfter == contractBalanceBefore) &&
                             (totalTransfersAfter == totalTransfersBefore) &&
                             (recipientBalanceAfter == recipientBalanceBefore);

        if (stateUnchanged) {
            console.log("Vulnerability Exists: Call reverted with unchanged state");
        } else {
            console.log("Vulnerability not Exist: State changed unexpectedly");
        }
    }
}