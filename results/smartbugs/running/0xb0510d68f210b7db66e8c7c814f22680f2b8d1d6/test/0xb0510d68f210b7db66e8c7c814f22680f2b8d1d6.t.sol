// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb0510d68f210b7db66e8c7c814f22680f2b8d1d6.sol";

contract SplitterTest is Test {
    Splitter splitter;
    address owner = address(0x1);

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.prank(owner);
        splitter = new Splitter();
    }

    function testUncheckedLowLevelCalls() public {
        // Create a non-payable contract to simulate failure
        address nonPayableAddress = address(new NonPayableContract());
        
        // Replace one of the puppets with a non-payable address
        vm.prank(owner);
        splitter.setExtra(0, nonPayableAddress);

        // Fund the contract
        vm.deal(address(splitter), 1 ether);
        uint256 initialBalance = address(splitter).balance;

        console2.log("--- BEFORE-Trigger Balance ---");
        uint256 preBal = address(splitter).balance;
        console2.log("Pre-Trigger Splitter Balance:", preBal);

        console2.log("--- Trigger FundPuppets ---");
        // Attempt to fund puppets - should silently fail for one transfer
        vm.prank(owner);
        splitter.fundPuppets{value: 1 ether}();

        console2.log("--- AFTER-Trigger Balance ---");
        uint256 postBal = address(splitter).balance;
        console2.log("Post-Trigger Splitter Balance:", postBal);
        uint256 balanceChange = postBal - preBal;
        console2.log("Balance change:", balanceChange);

        // Check balances:
        // - Initial balance was 1 ether
        // - Sent 1 ether (total 2 ether)
        // - 3 successful transfers of 0.25 ether each (0.75 ether sent)
        // - 1 failed transfer (0.25 ether remains)
        uint256 remainingBalance = address(splitter).balance;
        uint256 expectedRemaining = 1.25 ether; // 2 ether total - 0.75 ether sent
        
        assertEq(
            remainingBalance,
            expectedRemaining,
            "Funds were not properly distributed due to unchecked call"
        );

        // Differential verification: balance should increase by exactly 0.25 ether
        if (balanceChange == 0.25 ether) {
            console2.log("Vulnerability Exists: Contract balance increased by 0.25 ether due to failed transfer");
        } else {
            console2.log("Vulnerability not Exist: Contract balance change did not match vulnerability pattern");
        }
    }
}

contract NonPayableContract {
    // This contract doesn't have a payable fallback function
    // So it will reject any ether transfers
    constructor() payable {}
}