// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x958a8f594101d2c0485a52319f29b2647f2ebc06.sol";

contract MarriageTest is Test {
    Marriage marriage;
    address owner = address(0x1);
    address attacker = address(0x2);
    MockContract callTarget;

    function setUp() public {
        vm.prank(owner);
        marriage = new Marriage(owner);
        
        // Create a new mock contract that rejects all transfers by default
        callTarget = new MockContract();
        callTarget.setShouldRevert(true); // Default to reverting
    }

    function testUncheckedLowLevelCall() public {
        uint256 sendAmount = 1 ether;

        // Fund the marriage contract
        vm.deal(address(marriage), sendAmount);

        console.log("--- BEFORE-Trigger ---");
        uint256 callTargetBalanceBefore = address(callTarget).balance;
        uint256 marriageBalanceBefore = address(marriage).balance;
        console.log("Target contract balance before:", callTargetBalanceBefore);
        console.log("Marriage contract balance before:", marriageBalanceBefore);

        // Prepare malicious call data
        bytes memory maliciousData = abi.encodeWithSignature("nonExistingFunction()");

        console.log("--- Trigger Execute Call ---");
        vm.prank(owner);
        marriage.execute(address(callTarget), sendAmount, maliciousData);

        console.log("--- AFTER-Trigger ---");
        uint256 callTargetBalanceAfter = address(callTarget).balance;
        uint256 marriageBalanceAfter = address(marriage).balance;
        console.log("Target contract balance after:", callTargetBalanceAfter);
        console.log("Marriage contract balance after:", marriageBalanceAfter);

        // Compare balances
        bool balancesUnchanged = (callTargetBalanceAfter == callTargetBalanceBefore) && 
                                (marriageBalanceAfter == marriageBalanceBefore);
        
        if (balancesUnchanged) {
            console.log("VULNERABILITY VERIFIED: Balances unchanged after failed call");
            console.log("Vulnerability Exists: Transaction succeeded without changing balances, showing failed call not reverted");
        } else {
            console.log("BALANCES CHANGED UNEXPECTEDLY");
            console.log("Vulnerability not Exist: Balances changed indicating proper revert occurred");
        }

        // Final assertion to pass/fail test
        assertTrue(balancesUnchanged, "Expected contract balances to remain unchanged");
    }

    function testUncheckedLowLevelCallWithRevert() public {
        uint256 sendAmount = 1 ether;

        // Fund the marriage contract
        vm.deal(address(marriage), sendAmount);

        console.log("--- BEFORE-Trigger ---");
        uint256 callTargetBalanceBefore = address(callTarget).balance;
        uint256 marriageBalanceBefore = address(marriage).balance;
        console.log("Target contract balance before:", callTargetBalanceBefore);
        console.log("Marriage contract balance before:", marriageBalanceBefore);

        // Prepare malicious call data
        bytes memory maliciousData = abi.encodeWithSignature("nonExistingFunction()");

        console.log("--- Trigger Execute Call ---");
        vm.prank(owner);
        marriage.execute(address(callTarget), sendAmount, maliciousData);

        console.log("--- AFTER-Trigger ---");
        uint256 callTargetBalanceAfter = address(callTarget).balance;
        uint256 marriageBalanceAfter = address(marriage).balance;
        console.log("Target contract balance after:", callTargetBalanceAfter);
        console.log("Marriage contract balance after:", marriageBalanceAfter);

        // Compare balances
        bool balancesUnchanged = (callTargetBalanceAfter == callTargetBalanceBefore) && 
                                (marriageBalanceAfter == marriageBalanceBefore);
        
        if (balancesUnchanged) {
            console.log("VULNERABILITY VERIFIED: Balances unchanged after failed call");
            console.log("Vulnerability Exists: Transaction succeeded without changing balances, showing failed call not reverted");
        } else {
            console.log("BALANCES CHANGED UNEXPECTEDLY");
            console.log("Vulnerability not Exist: Balances changed indicating proper revert occurred");
        }

        // Final assertion to pass/fail test
        assertTrue(balancesUnchanged, "Expected contract balances to remain unchanged");
    }
}

contract MockContract {
    bool public shouldRevert;

    function setShouldRevert(bool _shouldRevert) public {
        shouldRevert = _shouldRevert;
    }

    receive() external payable {
        if (shouldRevert) {
            revert("MockContract: forced revert");
        }
    }

    fallback() external payable {
        if (shouldRevert) {
            revert("MockContract: forced revert");
        }
        // If not reverting, accept the transfer
    }
}