// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x7a4349a749e59a5736efb7826ee3496a2dfd5489.sol";

contract WhaleGiveaway1Test is Test {
    WhaleGiveaway1 public giveaway;
    address public attacker = makeAddr("attacker");

    function setUp() public {
        vm.deal(address(this), 1 ether);
        vm.deal(attacker, 1.1 ether);
        
        giveaway = new WhaleGiveaway1();
        payable(address(giveaway)).transfer(1 ether);
    }

    // Enable contract to receive Ether from WhaleGiveaway1
    receive() external payable {}

    function test_GetFreebieDrainsContractBalance() public {
        console2.log("--- BEFORE-Trigger Balances ---");
        uint256 initialContractBalance = address(giveaway).balance;
        uint256 initialOwnerBalance = address(this).balance;
        uint256 initialAttackerBalance = attacker.balance;
        console2.log("contract_balance: %s", initialContractBalance);
        console2.log("owner_balance: %s", initialOwnerBalance);
        console2.log("attacker_balance: %s", initialAttackerBalance);

        console2.log("--- TRIGGER :: attacker calls GetFreebie(1.1 ether) ---");
        vm.prank(attacker);
        giveaway.GetFreebie{value: 1.1 ether}();
        console2.log("--- AFTER-Trigger Balances ---");
        
        uint256 finalContractBalance = address(giveaway).balance;
        uint256 finalOwnerBalance = address(this).balance;
        uint256 finalAttackerBalance = attacker.balance;
        console2.log("contract_balance: %s", finalContractBalance);
        console2.log("owner_balance: %s", finalOwnerBalance);
        console2.log("attacker_balance: %s", finalAttackerBalance);

        bool contractDrained = finalContractBalance == 0;
        bool ownerGained = finalOwnerBalance == initialOwnerBalance + initialContractBalance + 1.1 ether;
        bool attackerLost = finalAttackerBalance == 0;

        if (contractDrained && ownerGained && attackerLost) {
            console2.log("Verdict: Vulnerability Exists");
            console2.log("Vulnerability Exists: Contract balance drained, owner gained funds, attacker lost entire balance");
        } else {
            console2.log("Verdict: Vulnerability not Exist");
            if (!contractDrained) console2.log("- Contract not drained (remaining: %s)", finalContractBalance);
            if (!ownerGained) console2.log("- Owner gain incorrect (expected: %s, actual: %s)", 
                initialOwnerBalance + initialContractBalance + 1.1 ether, finalOwnerBalance);
            if (!attackerLost) console2.log("- Attacker funds not drained (remaining: %s)", finalAttackerBalance);
            console2.log("Vulnerability not Exist: Exploit failed to trigger all expected effects");
        }

        assertEq(finalContractBalance, 0, "Contract balance should be drained to 0");
        assertEq(finalOwnerBalance, initialOwnerBalance + 2.1 ether, "Owner should receive full contract balance");
        assertEq(attacker.balance, 0, "Attacker should lose their contribution");
    }
}