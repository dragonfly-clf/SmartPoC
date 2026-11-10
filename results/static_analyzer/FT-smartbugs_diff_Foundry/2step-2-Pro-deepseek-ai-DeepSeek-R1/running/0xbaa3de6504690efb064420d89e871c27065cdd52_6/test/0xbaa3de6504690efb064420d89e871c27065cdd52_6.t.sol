// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbaa3de6504690efb064420d89e871c27065cdd52.sol";

contract VaultProxyTest is Test {
    VaultProxy vault;
    
    // Reusable addresses
    address user = makeAddr("user");
    address zeroAddress = address(0);
    address nonZeroContract;
    
    function setUp() public {
        // Deploy vulnerable VaultProxy contract
        vault = new VaultProxy();
        
        // Create a test contract for valid calls
        nonZeroContract = address(new MockContract());
    }

    function test_ProxyBurnsEthWithZeroAddress() public {
        // Capture PRE-attack state
        console.log("--- PRE-Trigger State ---");
        uint256 initialZeroBalance = address(0).balance;
        uint256 sendAmount = 1 ether;
        console.log("Zero address ETH balance:", initialZeroBalance);
        console.log("User ETH balance:", user.balance);
        console.log("Proxy ETH balance:", address(vault).balance);
        console.log("");

        // Execute attack
        console.log("--- Trigger ---");
        console.log("Malicious call: proxy{value: 1 ether}(0x0, 'malicious data')");
        vm.deal(user, sendAmount);
        vm.prank(user);
        vault.proxy{value: sendAmount}(zeroAddress, "malicious data");
        console.log("");

        // Capture POST-attack state
        console.log("--- POST-Trigger State ---");
        uint256 finalZeroBalance = address(0).balance;
        console.log("Zero address ETH balance:", finalZeroBalance);
        console.log("");

        // Differential verification
        console.log("--- Verification ---");
        uint256 balanceDiff = finalZeroBalance - initialZeroBalance;
        console.log("Zero address balance change:", balanceDiff, "wei");
        
        if (balanceDiff == sendAmount) {
            console.log("Vulnerability Exists: ETH was burned by zero-address transfer");
        } else {
            console.log("Vulnerability not Exist: Zero address balance didn't change as expected");
        }
    }

    function test_ProxyAcceptsEmptyData() public {
        // Capture PRE-attack state
        console.log("--- PRE-Trigger State ---");
        uint256 initialContractBalance = nonZeroContract.balance;
        console.log("Target contract ETH balance:", initialContractBalance);
        console.log("");

        // Execute attack
        console.log("--- Trigger ---");
        console.log("Call with empty data: proxy(target, '')");
        vault.proxy(nonZeroContract, "");
        console.log("");

        // Capture POST-attack state
        console.log("--- POST-Trigger State ---");
        uint256 finalContractBalance = nonZeroContract.balance;
        console.log("Target contract ETH balance:", finalContractBalance);
        console.log("");

        // Differential verification
        console.log("--- Verification ---");
        bool balanceUnchanged = finalContractBalance == initialContractBalance;
        console.log("Balance unchanged:", balanceUnchanged ? "YES" : "NO");
        
        if (balanceUnchanged) {
            console.log("Vulnerability Exists: Proxy accepted empty data call without state change");
        } else {
            console.log("Vulnerability not Exist: Unexpected state change occurred");
        }
    }
}

contract MockContract {
    fallback() external payable {}
}