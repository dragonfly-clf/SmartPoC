// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/simple_dao.sol";

contract SimpleDAOLackOfAccessControlTest is Test {
    SimpleDAO public dao;
    address public user;

    function setUp() public {
        dao = new SimpleDAO();
        user = makeAddr("user");
        vm.deal(user, 1 ether);
    }

    function test_DonateToZeroAddressIsAllowed() public {
        address zeroAddress = address(0);
        uint256 donationAmount = 1 ether;

        // Record initial state
        uint256 initialContractBalance = address(dao).balance;
        uint256 initialZeroCredit = dao.queryCredit(zeroAddress);

        console2.log("--- BEFORE-Trigger State ---");
        console2.log("Contract Balance: ", initialContractBalance);
        console2.log("Zero Address Credit: ", initialZeroCredit);
        console2.log("");
        
        console2.log("--- Trigger: donate %s to zero address ---", donationAmount);
        vm.prank(user);
        dao.donate{value: donationAmount}(zeroAddress);

        uint256 newContractBalance = address(dao).balance;
        uint256 newZeroCredit = dao.queryCredit(zeroAddress);

        console2.log("");
        console2.log("--- AFTER-Trigger State ---");
        console2.log("Contract Balance: ", newContractBalance);
        console2.log("Zero Address Credit: ", newZeroCredit);

        // Calculate expected changes
        bool contractBalanceIncreased = newContractBalance == initialContractBalance + donationAmount;
        bool creditIncreased = newZeroCredit == initialZeroCredit + donationAmount;
        bool vulnerabilityExists = contractBalanceIncreased && creditIncreased;

        // Final explicit verdict
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Donation to zero address succeeded and modified state");
        } else {
            console2.log("Vulnerability not Exist: State changes did not occur as expected");
        }

        // Existing assertions preserved
        assertEq(newContractBalance, initialContractBalance + donationAmount);
        assertEq(newZeroCredit, initialZeroCredit + donationAmount);
    }

    function test_DonateZeroValueIsAllowed() public {
        address recipient = makeAddr("recipient");

        uint256 initialContractBalance = address(dao).balance;
        uint256 initialRecipientCredit = dao.queryCredit(recipient);

        console2.log("--- BEFORE-Trigger State ---");
        console2.log("Contract Balance: ", initialContractBalance);
        console2.log("Recipient Credit: ", initialRecipientCredit);
        console2.log("");
        
        console2.log("--- Trigger: donate 0 ETH to recipient %s ---", recipient);
        vm.prank(user);
        dao.donate{value: 0}(recipient);

        uint256 newContractBalance = address(dao).balance;
        uint256 newRecipientCredit = dao.queryCredit(recipient);

        console2.log("");
        console2.log("--- AFTER-Trigger State ---");
        console2.log("Contract Balance: ", newContractBalance);
        console2.log("Recipient Credit: ", newRecipientCredit);

        // Verify state remains unchanged
        bool contractBalanceUnchanged = newContractBalance == initialContractBalance;
        bool creditUnchanged = newRecipientCredit == initialRecipientCredit;
        bool vulnerabilityExists = contractBalanceUnchanged && creditUnchanged;

        // Final explicit verdict
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Zero-value donation allowed and state unchanged");
        } else {
            console2.log("Vulnerability not Exist: State unexpectedly changed after zero-value donation");
        }

        // Existing assertions preserved and extended
        assertEq(newContractBalance, initialContractBalance);
        assertEq(newRecipientCredit, initialRecipientCredit);
    }
}