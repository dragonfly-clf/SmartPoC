// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/HaggleToken.sol";

contract HXTokenTest is Test {
    HaggleXToken token;
    address owner = address(0x1);
    address userA = address(0xA);
    uint256 stakeAmount = 10 ether;

    function setUp() public {
        vm.startPrank(owner);
        token = new HaggleXToken();
        token.mint(userA, stakeAmount);
        vm.stopPrank();
    }

    function testAtomicityViolationOnFailedMint() public {
        // Setup stake
        vm.startPrank(userA);
        token.approve(address(token), stakeAmount);
        token.stake(stakeAmount, 9); // Stake type 9 (test option)

        // Advance time to pass initial withdrawal conditions
        skip(12 minutes); // Type 9 has 20min lock, but only need +10min for withdrawal

        console.log("--- BEFORE-Trigger State ---");
        uint256 preWithdrawals = token.getNoOfWithdrawals(0);
        uint256 preLastTime = token.getLastWithdrawalTime(0);
        console.log("Pre-withdrawal count:", preWithdrawals);
        console.log("Pre-last withdrawal time:", preLastTime);
        console.log("");

        // Blacklist userA to cause mint failure
        console.log("--- Trigger Action (Blacklist & Attempt Withdrawal) ---");
        vm.startPrank(owner);
        token.blacklist(userA);
        vm.stopPrank();

        // Attempt withdrawal (should revert)
        vm.startPrank(userA);
        vm.expectRevert("HaggleX Token: account to mint to already blacklisted");
        token.withdrawStakeReward(0);
        vm.stopPrank();

        console.log("");
        console.log("--- AFTER-Trigger State ---");
        uint256 postWithdrawals;
        uint256 postLastTime;
        bool withdrawalsReadSucc;
        bool lastTimeReadSucc;

        // Try/catch for withdrawal count
        try token.getNoOfWithdrawals(0) returns (uint256 _v) {
            postWithdrawals = _v;
            withdrawalsReadSucc = true;
            console.log("Post-withdrawal count (read succeeded):", postWithdrawals);
        } catch {
            withdrawalsReadSucc = false;
            console.log("Post-withdrawal count read FAILED");
        }

        // Try/catch for last withdrawal time
        try token.getLastWithdrawalTime(0) returns (uint256 _v) {
            postLastTime = _v;
            lastTimeReadSucc = true;
            console.log("Post-last withdrawal time (read succeeded):", postLastTime);
        } catch {
            lastTimeReadSucc = false;
            console.log("Post-last withdrawal time read FAILED");
        }
        console.log("");

        console.log("--- Differential Result ---");
        bool withdrawalsChanged;
        bool lastTimeChanged;

        if (withdrawalsReadSucc) {
            withdrawalsChanged = preWithdrawals != postWithdrawals;
            console.log("Withdrawal count changed:", withdrawalsChanged ? "YES" : "NO");
        } else {
            withdrawalsChanged = true;
            console.log("Withdrawal count status: READ FAILED (state corrupted)");
        }

        if (lastTimeReadSucc) {
            lastTimeChanged = preLastTime != postLastTime;
            console.log("Last withdrawal time changed:", lastTimeChanged ? "YES" : "NO");
        } else {
            lastTimeChanged = true;
            console.log("Last withdrawal time status: READ FAILED (state corrupted)");
        }

        // Final vulnerability verdict
        bool stateChanged = withdrawalsChanged || lastTimeChanged;
        if (stateChanged) {
            console.log("Vulnerability Exists: State altered despite failed withdrawal");
        } else {
            console.log("Vulnerability not Exist: State remained unchanged");
        }
    }
}