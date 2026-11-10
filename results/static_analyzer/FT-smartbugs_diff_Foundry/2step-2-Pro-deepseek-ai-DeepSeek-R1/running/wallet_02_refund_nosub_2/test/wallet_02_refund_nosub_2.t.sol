// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/wallet_02_refund_nosub.sol";

contract WalletDepositOverflowTest is Test {
    Wallet public wallet;
    address internal user;
    uint256 internal constant MAX_UINT256 = type(uint256).max;

    function setUp() public {
        wallet = new Wallet();
        user = address(1);
    }

    function test_depositRevertsOnOverflow() public {
        // Set user's balance to MAX_UINT256 via storage cheat
        uint256 mappingSlot = 1; // balances mapping slot (slot 0 for creator, slot 1 for mapping)
        bytes32 userBalanceSlot = keccak256(abi.encode(user, mappingSlot));
        vm.store(address(wallet), userBalanceSlot, bytes32(MAX_UINT256));

        // Verify storage setup
        assertEq(wallet.getBalance(user), MAX_UINT256, "Balance setup failed");

        // Capture initial state
        console.log("--- BEFORE-Trigger ---");
        uint initialBalance = wallet.getBalance(user);
        uint initialTotalDeposits = wallet.totalDeposits();
        uint initialDepositCount = wallet.depositCount(user);
        console.log("User balance:", initialBalance);
        console.log("Total deposits:", initialTotalDeposits);
        console.log("User deposit count:", initialDepositCount);

        // Prepare user deposit
        vm.deal(user, 1 wei);

        console.log("\n--- Trigger Operation ---");
        console.log("Attempt: deposit overflow (1 wei to MAX_UINT256 user)");

        // Attempt deposit (expected to revert)
        vm.prank(user);
        vm.expectRevert(stdError.assertionError); 
        wallet.deposit{value: 1 wei}();

        console.log("\n--- AFTER-Trigger ---");
        // Capture post-statem
        uint postBalance = wallet.getBalance(user);
        uint postTotalDeposits = wallet.totalDeposits();
        uint postDepositCount = wallet.depositCount(user);
        console.log("User balance:", postBalance);
        console.log("Total deposits:", postTotalDeposits);
        console.log("User deposit count:", postDepositCount);

        // Verify states unchanged
        bool unchanged = (initialBalance == postBalance) &&
                         (initialTotalDeposits == postTotalDeposits) &&
                         (initialDepositCount == postDepositCount);

        console.log("\n--- Verdict ---");
        console.log("State unchanged:", unchanged);

        // Final vulnerability verdict
        if (unchanged) {
            console.log("Vulnerability not Exist: State preserved due to revert on overflow");
        } else {
            console.log("Vulnerability Exists: State changed after overflow attempt");
        }
    }
}