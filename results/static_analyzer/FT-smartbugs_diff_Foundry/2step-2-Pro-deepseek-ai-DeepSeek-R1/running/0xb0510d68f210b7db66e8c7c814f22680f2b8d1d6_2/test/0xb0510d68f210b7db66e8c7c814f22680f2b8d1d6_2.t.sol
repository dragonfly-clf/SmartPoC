// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb0510d68f210b7db66e8c7c814f22680f2b8d1d6.sol";

// Contract that reverts when receiving ETH
contract Reverter {
    receive() external payable {
        revert("Revert on receive");
    }
}

// Contract that simply accepts ETH without processing
contract Acceptor {
    receive() external payable {}
}

contract SplitterTest is Test {
    Splitter public splitter;

    function setUp() public {
        splitter = new Splitter();
    }

    function test_FundPuppetsWithUncheckedReturn() public {
        // Deploy test contracts
        Reverter reverter = new Reverter();
        Acceptor acceptor1 = new Acceptor();
        Acceptor acceptor2 = new Acceptor();
        Acceptor acceptor3 = new Acceptor();

        // Replace all extra addresses with test contracts
        splitter.setExtra(0, address(reverter));
        splitter.setExtra(1, address(acceptor1));
        splitter.setExtra(2, address(acceptor2));
        splitter.setExtra(3, address(acceptor3));

        // Record initial balances
        uint256 beforeReverter = address(reverter).balance;
        uint256 beforeAcceptor1 = address(acceptor1).balance;
        uint256 beforeAcceptor2 = address(acceptor2).balance;
        uint256 beforeAcceptor3 = address(acceptor3).balance;
        uint256 beforeSplitter = address(splitter).balance;
        uint256 fundAmount = 4 ether;

        console.log("--- BEFORE-Trigger fundPuppets ---");
        console.log("Reverter balance: %d wei", beforeReverter);
        console.log("Acceptor1 balance: %d wei", beforeAcceptor1);
        console.log("Acceptor2 balance: %d wei", beforeAcceptor2);
        console.log("Acceptor3 balance: %d wei", beforeAcceptor3);
        console.log("Splitter balance: %d wei", beforeSplitter);
        
        console.log("--- Trigger fundPuppets ---");
        // Fund as contract owner
        hoax(splitter.owner(), fundAmount);
        splitter.fundPuppets{value: fundAmount}();

        console.log("--- AFTER-Trigger fundPuppets ---");
        uint256 afterReverter = address(reverter).balance;
        uint256 afterAcceptor1 = address(acceptor1).balance;
        uint256 afterAcceptor2 = address(acceptor2).balance;
        uint256 afterAcceptor3 = address(acceptor3).balance;
        uint256 afterSplitter = address(splitter).balance;

        console.log("Reverter balance: %d wei (Difference: %d)", afterReverter, afterReverter - beforeReverter);
        console.log("Acceptor1 balance: %d wei (Difference: %d)", afterAcceptor1, afterAcceptor1 - beforeAcceptor1);
        console.log("Acceptor2 balance: %d wei (Difference: %d)", afterAcceptor2, afterAcceptor2 - beforeAcceptor2);
        console.log("Acceptor3 balance: %d wei (Difference: %d)", afterAcceptor3, afterAcceptor3 - beforeAcceptor3);
        console.log("Splitter balance: %d wei (Difference: %d)", afterSplitter, afterSplitter - beforeSplitter);

        // Vulnerability verification
        bool reverterUnchanged = (afterReverter == beforeReverter);
        bool acceptor1Increased = (afterAcceptor1 == beforeAcceptor1 + 1 ether);
        bool acceptor2Increased = (afterAcceptor2 == beforeAcceptor2 + 1 ether);
        bool acceptor3Increased = (afterAcceptor3 == beforeAcceptor3 + 1 ether);
        bool splitterBalanced = (afterSplitter == beforeSplitter + fundAmount - 3 ether);
        
        console.log("Vulnerability indicators:");
        console.log("Reverter unchanged: %s", reverterUnchanged ? "YES" : "NO");
        console.log("Acceptor1 increase: %s", acceptor1Increased ? "YES" : "NO");
        console.log("Acceptor2 increase: %s", acceptor2Increased ? "YES" : "NO");
        console.log("Acceptor3 increase: %s", acceptor3Increased ? "YES" : "NO");
        console.log("Splitter balance matches: %s", splitterBalanced ? "YES" : "NO");

        if (reverterUnchanged && acceptor1Increased && acceptor2Increased && acceptor3Increased && splitterBalanced) {
            console.log("Vulnerability Exists: Failed ETH transfer was not checked, acceptors received ETH");
        } else {
            console.log("Vulnerability not Exist: No evidence of unchecked failed transfers");
        }
    }
}