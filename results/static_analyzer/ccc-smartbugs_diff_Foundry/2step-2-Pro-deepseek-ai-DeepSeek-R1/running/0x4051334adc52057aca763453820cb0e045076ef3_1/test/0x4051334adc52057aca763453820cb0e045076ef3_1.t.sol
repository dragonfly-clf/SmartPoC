// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4051334adc52057aca763453820cb0e045076ef3.sol";

contract MockToken {
    function transferFrom(address, address, uint256) public pure returns (bool) {
        return true;
    }
}

contract AirdropTest is Test {
    airdrop public airdropContract;
    MockToken public token;
    address from = address(0x01);
    address[] users;
    uint256 constant MAX_UINT = type(uint256).max;

    function setUp() public {
        airdropContract = new airdrop();
        token = new MockToken();
    }

    // Test potential overflow in totalTokensDistributed calculation
    function test_TransferOverflowTotalTokens() public {
        // Arrange - create overflow condition: (2 * (MAX_UINT/2 + 1) = MAX_UINT + 2 → overflow
        users.push(address(0x10));
        users.push(address(0x11));
        uint256 amount = MAX_UINT / 2 + 1;

        // Before: State capture
        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 totalBefore = airdropContract.totalTokensDistributed();
        console.log("totalTokensDistributed: %s", totalBefore);
        uint256[] memory userBefore = new uint256[](users.length);
        for (uint i = 0; i < users.length; i++) {
            userBefore[i] = airdropContract.userTokensReceived(users[i]);
            console.log("userTokensReceived[%s]: %s", users[i], userBefore[i]);
        }

        // Trigger: Expected overflow reversion point
        console.log("--- Trigger Transfer (expected to overflow) ---");
        vm.expectRevert(stdError.arithmeticError);
        airdropContract.transfer(from, address(token), users, amount);

        // After: State re-capture and comparison
        console.log("--- AFTER-Trigger Transfer ---");
        uint256 totalAfter = airdropContract.totalTokensDistributed();
        console.log("totalTokensDistributed: %s", totalAfter);
        bool unchanged = (totalBefore == totalAfter);

        uint256[] memory userAfter = new uint256[](users.length);
        for (uint i = 0; i < users.length; i++) {
            userAfter[i] = airdropContract.userTokensReceived(users[i]);
            console.log("userTokensReceived[%s]: %s", users[i], userAfter[i]);
            unchanged = unchanged && (userBefore[i] == userAfter[i]);
        }

        // Vulnerability verdict
        if (unchanged) {
            console.log("Vulnerability not Exist: Expected overflow reverted harmlessly without state changes.");
        } else {
            console.log("Vulnerability Exists: State inconsistency detected despite revert!");
        }

        // Final assertion
        assertTrue(unchanged, "Critical: State changed after revert");
    }

    // Test potential overflow in individual token tracking
    function test_TransferOverflowUserBalance() public {
        // Arrange - setup overflow scenario
        users.push(address(this));
        uint256 firstTransfer = MAX_UINT - 99;
        uint256 secondTransfer = 100; // First transfer + 1 will overflow uint256

        // Initial setup transfer (expected to succeed)
        airdropContract.transfer(from, address(token), users, firstTransfer);

        // Before: State capture for critical operation
        console.log("--- BEFORE-Trigger Transfer (second) ---");
        uint256 totalBefore = airdropContract.totalTokensDistributed();
        console.log("totalTokensDistributed: %s", totalBefore);
        uint256 userBefore = airdropContract.userTokensReceived(address(this));
        console.log("userTokensReceived[%s]: %s", address(this), userBefore);

        // Trigger: Expected overflow reversion point
        console.log("--- Trigger Transfer (second) expected to overflow ---");
        vm.expectRevert(stdError.arithmeticError);
        airdropContract.transfer(from, address(token), users, secondTransfer);

        // After: State re-capture and comparison
        console.log("--- AFTER-Trigger Transfer (second) ---");
        uint256 totalAfter = airdropContract.totalTokensDistributed();
        console.log("totalTokensDistributed: %s", totalAfter);
        uint256 userAfter = airdropContract.userTokensReceived(address(this));
        console.log("userTokensReceived[%s]: %s", address(this), userAfter);

        bool unchanged = (totalBefore == totalAfter && userBefore == userAfter);
        
        // Vulnerability verdict
        if (unchanged) {
            console.log("Vulnerability not Exist: Expected overflow reverted harmlessly without state changes.");
        } else {
            console.log("Vulnerability Exists: State inconsistency detected despite revert!");
        }

        // Final assertion
        assertTrue(unchanged, "Critical: State changed after revert");
    }
}