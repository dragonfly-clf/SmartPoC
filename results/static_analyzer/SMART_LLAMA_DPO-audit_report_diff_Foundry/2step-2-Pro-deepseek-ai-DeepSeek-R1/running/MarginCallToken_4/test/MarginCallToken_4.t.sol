// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MarginCallToken.sol";

contract MarginCallTokenPrivilegeTest is Test {
    MarginCallToken token;
    address constant owner = address(0x12345);

    function setUp() public {
        vm.startPrank(owner);
        
        // Mock Uniswap router and factory calls during deployment
        address fakeFactory = address(0xFAC70EE);
        address fakePair = address(0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF);
        
        // Mock router factory() call
        vm.mockCall(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
            abi.encodeWithSignature("factory()"),
            abi.encode(fakeFactory)
        );
        
        // Mock router WETH() call
        vm.mockCall(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
            abi.encodeWithSignature("WETH()"),
            abi.encode(address(0xBEEF))
        );
        
        // Mock factory createPair() call
        vm.mockCall(
            fakeFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(fakePair)
        );

        // Deploy token with mocked dependencies
        token = new MarginCallToken();
        vm.stopPrank();
    }

    function testOwnerCanDrainAllFunds() public {
        // Fund contract with 1 ether
        deal(address(token), 1 ether);
        
        // BEFORE: Record initial balances
        uint256 contractBalanceBefore = address(token).balance;
        uint256 ownerBalanceBefore = owner.balance;
        
        console.log("--- BEFORE-Trigger: clearBNB ---");
        console.log("Contract ETH balance:", contractBalanceBefore);
        console.log("Owner ETH balance:", ownerBalanceBefore);

        console.log("--- Trigger: clearBNB ---");
        // Owner drains contract funds
        vm.prank(owner);
        token.clearBNB();

        // AFTER: Record balances after drain
        uint256 contractBalanceAfter = address(token).balance;
        uint256 ownerBalanceAfter = owner.balance;
        
        console.log("--- AFTER-Trigger: clearBNB ---");
        console.log("Contract ETH balance:", contractBalanceAfter);
        console.log("Owner ETH balance:", ownerBalanceAfter);

        // Calculate balance changes
        uint256 contractBalanceLoss = contractBalanceBefore - contractBalanceAfter;
        uint256 ownerBalanceGain = ownerBalanceAfter - ownerBalanceBefore;
        bool fundsTransferred = ownerBalanceGain == contractBalanceLoss;
        bool contractDrained = contractBalanceAfter == 0;

        console.log("Verdict:");
        console.log("Funds transferred to owner:", fundsTransferred ? "YES" : "NO");
        console.log("Contract fully drained:", contractDrained ? "YES" : "NO");
        
        // Check if vulnerability was exploited
        if (contractDrained && fundsTransferred) {
            console.log("Vulnerability Exists: Owner successfully drained contract ETH balance");
        } else {
            console.log("Vulnerability not Exist: clearBNB failed to transfer funds as expected");
        }
    }
}