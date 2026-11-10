// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/EKARTINU.sol";

contract MaliciousToken {
    EKARTINU public victim;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    bool private _isReentering;

    constructor(address victimAddress, address initialHolder, uint256 initialSupply) {
        victim = EKARTINU(victimAddress);
        _balances[initialHolder] = initialSupply;
        _totalSupply = initialSupply;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(_balances[msg.sender] >= amount, "Insufficient balance");

        // Reenter when called by victim contract
        if (msg.sender == address(victim) && !_isReentering) {
            _isReentering = true;
            victim.extractLostToken(address(this));
            _isReentering = false;
        }

        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        return true;
    }

    function allowance(address, address) external pure returns (uint256) {
        return 0;
    }

    function approve(address, uint256) external pure returns (bool) {
        return true;
    }

    function transferFrom(address, address, uint256) external pure returns (bool) {
        return true;
    }
}

contract ReentrancyTest is Test {
    EKARTINU public ekartinu;
    MaliciousToken public maliciousToken;
    address owner = address(1);
    address holder = address(3);
    uint256 initSupply = 1000 ether;

    function setUp() public {
        vm.startPrank(owner);
        ekartinu = new EKARTINU();
        vm.stopPrank();
        
        maliciousToken = new MaliciousToken(
            address(ekartinu),
            holder,
            initSupply
        );

        // Transfer tokens to EKARTINU contract
        vm.prank(holder);
        maliciousToken.transfer(address(ekartinu), initSupply);
    }

    function testReentrancyPrevented() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 balBefore = maliciousToken.balanceOf(address(ekartinu));
        console.log("Victim contract token balance before attack:", balBefore);

        console.log("--- Trigger Reentrancy Attack ---");
        vm.prank(owner);
        vm.expectRevert("ReentrancyGuard: reentrant call");
        ekartinu.extractLostToken(address(maliciousToken));

        console.log("--- AFTER-Trigger State ---");
        uint256 balAfter = maliciousToken.balanceOf(address(ekartinu));
        console.log("Victim contract token balance after attack:", balAfter);

        console.log("--- Differential Result ---");
        if (balBefore == balAfter) {
            console.log("Vulnerability not Exist: Reentrancy prevented - token balance unchanged");
        } else {
            console.log("Vulnerability Exists: Reentrancy occurred - token balance changed during attack");
        }
    }
}