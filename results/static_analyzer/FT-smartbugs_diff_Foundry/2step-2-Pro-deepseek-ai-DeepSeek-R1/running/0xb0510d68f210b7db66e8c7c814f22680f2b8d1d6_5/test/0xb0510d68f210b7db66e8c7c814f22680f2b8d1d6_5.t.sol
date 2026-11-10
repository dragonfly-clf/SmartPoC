// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb0510d68f210b7db66e8c7c814f22680f2b8d1d6.sol";
import "../src/0xb0510d68f210b7db66e8c7c814f22680f2b8d1d6.sol";

contract SplitterTest is Test {
    Splitter splitter;
    
    function setUp() public {
        // Deploy Splitter contract
        splitter = new Splitter();
    }
    
    function test_IntegerUnderflowInDivision() public {
        console2.log("--- BEFORE-Trigger State ---");
        address[] memory puppets = new address[](4);
        uint256[] memory puppetBalBefore = new uint256[](4);
        for (uint256 i = 0; i < 4; i++) {
            puppets[i] = splitter.extra(i);
            puppetBalBefore[i] = puppets[i].balance;
            console2.log("Puppet %s balance before: %s", i, puppetBalBefore[i]);
        }
        uint256 splitterBalanceBefore = address(splitter).balance;
        console2.log("Splitter contract balance before: %s", splitterBalanceBefore);
        
        // Fund test contract to enable ether sending
        vm.deal(address(this), 100 ether);
        
        console2.log("--- Trigger fundPuppets with 3 wei ---");
        // Call fundPuppets() with amount that triggers truncation
        (bool success,) = address(splitter).call{value: 3}(
            abi.encodeWithSignature("fundPuppets()")
        );
        
        // Verify the call didn't revert despite truncation
        assertTrue(success, "Call to fundPuppets() should not revert");
        
        console2.log("--- AFTER-Trigger State ---");
        uint256[] memory puppetBalAfter = new uint256[](4);
        bool allPuppetsUnchanged = true;
        for (uint256 i = 0; i < 4; i++) {
            puppetBalAfter[i] = puppets[i].balance;
            console2.log("Puppet %s balance after: %s", i, puppetBalAfter[i]);
            
            if(puppetBalAfter[i] != puppetBalBefore[i]) {
                allPuppetsUnchanged = false;
            }
        }
        uint256 splitterBalanceAfter = address(splitter).balance;
        console2.log("Splitter contract balance after: %s", splitterBalanceAfter);
        
        // Verify contract balance reflects partial allocation
        assertEq(
            splitterBalanceAfter, 
            splitterBalanceBefore + 3, 
            "All ether should remain in contract after truncated allocation"
        );
        
        // Final vulnerability verdict based on state changes
        if (allPuppetsUnchanged) {
            console2.log("Vulnerability Exists: Puppets balances remain unchanged indicating truncation vulnerability");
        } else {
            console2.log("Vulnerability not Exist: Funds were distributed to puppets as expected");
        }
    }

    function test_UncheckedArithmeticNotReverting() public {
        console2.log("--- BEFORE-Trigger State ---");
        address[] memory puppets = new address[](4);
        uint256[] memory puppetBalBefore = new uint256[](4);
        for (uint256 i = 0; i < 4; i++) {
            puppets[i] = splitter.extra(i);
            puppetBalBefore[i] = puppets[i].balance;
            console2.log("Puppet %s balance before: %s", i, puppetBalBefore[i]);
        }
        uint256 splitterBalanceBefore = address(splitter).balance;
        console2.log("Splitter contract balance before: %s", splitterBalanceBefore);
        
        // Fund test contract with large amount
        vm.deal(address(this), type(uint192).max);
        
        console2.log("--- Trigger fundPuppets with max uint192 value ---");
        // Call with extremely large value (potential overflow risk)
        (bool success,) = address(splitter).call{value: type(uint192).max}(
            abi.encodeWithSignature("fundPuppets()")
        );
        
        console2.log("--- AFTER-Trigger State ---");
        uint256[] memory puppetBalAfter = new uint256[](4);
        for (uint256 i = 0; i < 4; i++) {
            puppetBalAfter[i] = puppets[i].balance;
            console2.log("Puppet %s balance after: %s", i, puppetBalAfter[i]);
        }
        uint256 splitterBalanceAfter = address(splitter).balance;
        console2.log("Splitter contract balance after: %s", splitterBalanceAfter);
        
        // Should still succeed despite unchecked arithmetic
        assertTrue(success, "Call should succeed even with large values");
        
        // Final vulnerability verdict based on execution success
        if (success) {
            console2.log("Vulnerability Exists: Call with max value succeeded without reverting");
        } else {
            console2.log("Vulnerability not Exist: Call with max value reverted as expected");
        }
    }
}