// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xf70d589d76eebdd7c12cc5eec99f8f6fa4233b9e.sol";

contract WhaleGiveaway2Test is Test {
    WhaleGiveaway2 public giveaway;
    address public owner = address(0x123);
    address public nonOwner = address(0x456);
    MaliciousReceiver public maliciousContract;

    function setUp() public {
        vm.startPrank(owner);
        giveaway = new WhaleGiveaway2();
        maliciousContract = new MaliciousReceiver();
        vm.stopPrank();
    }

    function testNonOwnerCommandReverts() public {
        vm.prank(nonOwner);
        bytes memory data = abi.encodeWithSelector(MaliciousReceiver.setValue.selector, 42);
        vm.expectRevert();
        giveaway.Command(address(maliciousContract), data);
    }

    function testOwnerCanExecuteArbitraryCalls() public {
        uint256 newValue = 42;
        bytes memory data = abi.encodeWithSelector(MaliciousReceiver.setValue.selector, newValue);
        
        console.log("--- BEFORE-Trigger Command ---");
        uint256 preValue = maliciousContract.value();
        console.log("Malicious contract initial value: ", preValue);
        
        console.log("--- Trigger Command ---");
        vm.prank(owner);
        giveaway.Command(address(maliciousContract), data);
        
        console.log("--- AFTER-Trigger Command ---");
        uint256 postValue = maliciousContract.value();
        console.log("Malicious contract after value: ", postValue);
        
        assertEq(postValue, newValue, "Owner failed to execute arbitrary call");
        
        if (postValue == newValue) {
            console.log("Vulnerability Exists: Owner can execute arbitrary calls");
        } else {
            console.log("Vulnerability not Exist: State change failed");
        }
    }

    function testOwnerCanStealFundsViaCall() public {
        // Add ETH to malicious contract to simulate vulnerable state
        uint256 stolenAmount = 5 ether;
        deal(address(maliciousContract), stolenAmount);
        
        console.log("--- BEFORE-Trigger Command ---");
        uint256 preGiveawayBalance = address(giveaway).balance;
        uint256 preMaliciousBalance = address(maliciousContract).balance;
        uint256 preOwnerBalance = owner.balance;
        console.log("Initial Giveaway balance: ", preGiveawayBalance);
        console.log("Initial Malicious contract balance: ", preMaliciousBalance);
        console.log("Initial Owner balance: ", preOwnerBalance);
        
        console.log("--- Trigger Command ---");
        vm.prank(owner);
        giveaway.Command(
            address(maliciousContract),
            abi.encodeWithSelector(MaliciousReceiver.drain.selector, owner)
        );
        
        console.log("--- AFTER-Trigger Command ---");
        uint256 postGiveawayBalance = address(giveaway).balance;
        uint256 postMaliciousBalance = address(maliciousContract).balance;
        uint256 postOwnerBalance = owner.balance;
        console.log("Giveaway balance after: ", postGiveawayBalance);
        console.log("Malicious contract balance after: ", postMaliciousBalance);
        console.log("Owner balance after: ", postOwnerBalance);
        
        bool fundsStolen = (postMaliciousBalance == 0) && 
                           (postOwnerBalance == preOwnerBalance + stolenAmount);
        
        if (fundsStolen) {
            console.log("Vulnerability Exists: Funds successfully drained");
        } else {
            console.log("Vulnerability not Exist: Fund drain failed");
        }
    }
}

contract MaliciousReceiver {
    uint256 public value;
    function setValue(uint256 _value) public {
        value = _value;
    }
    
    function drain(address payable recipient) public payable {
        selfdestruct(recipient);
    }
    
    receive() external payable {}
}