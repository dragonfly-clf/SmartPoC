// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FidoMeta.sol";

contract FidometaTest is Test {
    Fidometa token;
    address owner = address(0x12345678);

    function setUp() public {
        vm.startPrank(owner);
        token = new Fidometa();
        vm.stopPrank();
    }

    function testBurnCausesExceededSupply() public {
        vm.startPrank(owner);
        token.excludeFromReward(owner);
        
        uint256 initialSupply = token.totalSupply();
        console2.log("--- BEFORE-Trigger Burn ---");
        console2.log("Total Supply: ", initialSupply);
        console2.log("Owner Balance: ", token.balanceOf(owner));
        assertEq(token.balanceOf(owner), initialSupply, "Initial owner balance mismatch");
        
        console2.log("--- Trigger Burn ---");
        console2.log("Burning entire supply: ", initialSupply);
        token.burn(initialSupply);
        vm.stopPrank();
        
        console2.log("--- AFTER-Trigger Burn ---");
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        console2.log("Total Supply: ", totalSupplyAfter);
        console2.log("Owner Balance: ", ownerBalanceAfter);
        
        // Vulnerability condition check
        bool vulnerabilityExists = (totalSupplyAfter == 0 && ownerBalanceAfter == initialSupply);
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Owner balance unchanged after burning entire supply");
        } else {
            console2.log("Vulnerability not Exist: Burn operation did not maintain owner balance while reducing supply to zero");
        }
        
        // Original assertions remain for test logic
        assertEq(totalSupplyAfter, 0, "Total supply should be zero");
        assertEq(ownerBalanceAfter, initialSupply, "Owner balance should remain unchanged");
    }
}