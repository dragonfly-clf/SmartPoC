// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/wallet_04_confused_sign.sol";

contract WalletTest is Test {
    Wallet public wallet;
    address user = makeAddr("user");

    function setUp() public {
        wallet = new Wallet();
        vm.deal(user, 2 ether);
    }

    function testPartialWithdrawalFailure() public {
        // Deposit funds
        vm.prank(user);
        wallet.deposit{value: 1 ether}();
        
        console2.log("--- BEFORE-Trigger Verification ---");
        uint256 preBalance = wallet.getBalance(user);
        uint256 preTotalWithdrawals = wallet.totalWithdrawals();
        console2.log("Pre-Withdrawal - User Balance: %s", preBalance);
        console2.log("Pre-Withdrawal - Contract Total Withdrawals: %s", preTotalWithdrawals);

        console2.log("--- Trigger Action (Partial Withdraw Attempt) ---");
        vm.prank(user);
        (bool success, ) = address(wallet).call(abi.encodeWithSelector(Wallet.withdraw.selector, 0.5 ether));

        console2.log("--- AFTER-Trigger Verification ---");
        uint256 postBalance = wallet.getBalance(user);
        uint256 postTotalWithdrawals = wallet.totalWithdrawals();
        console2.log("Post-Withdrawal - User Balance: %s", postBalance);
        console2.log("Post-Withdrawal - Contract Total Withdrawals: %s", postTotalWithdrawals);

        bool stateUnchanged = (preBalance == postBalance) && (preTotalWithdrawals == postTotalWithdrawals);
        if (success || !stateUnchanged) {
            console2.log("Vulnerability confirmed: State changed undesirably");
            console2.log("Vulnerability Exists: Partial withdrawal succeeded or state modified unexpectedly");
        } else {
            console2.log("Vulnerability not Exist: Withdrawal correctly blocked with unchanged state");
        }
    }
}