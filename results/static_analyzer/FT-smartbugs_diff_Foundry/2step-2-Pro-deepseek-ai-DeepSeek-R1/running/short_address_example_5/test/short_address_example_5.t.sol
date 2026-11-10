// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/short_address_example.sol";

contract TxOriginTest is Test {
    MyToken public token1;
    MyToken public token2;
    MyToken public victimToken;
    address victim = address(0x1111);
    address attacker = address(0x2222);
    address testRunner = tx.origin; // Stores test executor address

    function test_txOriginVulnerability() public {
        // 1. Normal deployment by testRunner
        TokenDeployer deployer1 = new TokenDeployer();
        token1 = deployer1.token();
        assertEq(token1.owner(), testRunner);
        assertEq(token1.getBalance(testRunner), 10000);

        // 2. Attacker deploys their own TokenDeployer
        vm.startPrank(attacker, attacker); // Sets both msg.sender AND tx.origin
        TokenDeployer deployer2 = new TokenDeployer();
        token2 = deployer2.token();
        vm.stopPrank();
        assertEq(token2.owner(), attacker);
        assertEq(token2.getBalance(attacker), 10000);

        // 3. Victim uses attacker's deployer contract
        vm.startPrank(victim, victim); // Sets victim as tx.origin
        deployer2.deployNewToken();
        victimToken = deployer2.newestToken();
        vm.stopPrank();
        assertEq(victimToken.owner(), victim);
        assertEq(victimToken.getBalance(victim), 10000);
        
        // Final vulnerability verdict
        console.log("Vulnerability not Exist: Victim maintains token ownership when deployed through attacker's contract");
    }
}

contract TokenDeployer {
    MyToken public token;
    MyToken public newestToken;

    constructor() {
        token = new MyToken();
    }

    function deployNewToken() public {
        newestToken = new MyToken();
    }
}