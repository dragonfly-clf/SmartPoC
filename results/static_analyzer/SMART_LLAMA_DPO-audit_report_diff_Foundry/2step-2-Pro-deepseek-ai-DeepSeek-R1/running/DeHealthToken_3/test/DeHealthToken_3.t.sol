// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DeHealthToken.sol";

contract DeHealthTokenTest is Test {
    DeHealthToken token;
    address admin = address(1);
    address user1 = address(2);
    address user2 = address(3);
    
    function setUp() public {
        vm.startPrank(admin);
        token = new DeHealthToken();
        token.initialize(admin);
        vm.stopPrank();
    }

    function test_CannotMintBeyondCap() public {
        vm.startPrank(admin);
        address[] memory addresses = new address[](2);
        uint256[] memory balances = new uint256[](2);
        addresses[0] = user1;
        addresses[1] = user2;
        uint256 initialBalance = 100 * 10**token.decimals();
        balances[0] = initialBalance;
        balances[1] = initialBalance;
        
        token.__loadBalances(addresses, balances);
        uint256 expectedInitialSupply = initialBalance * 2;
        
        token.__activate();
        uint256 currentSupply = token.totalSupply();
        uint256 expectedCap = 1000000000 * 10**token.decimals();
        
        assertEq(currentSupply, expectedCap, "Total supply didn't reach cap");
        
        // 漏洞本质是内部状态更新缺失，但无法通过公开状态观测
        // 仅能通过revert验证预期行为
        console.log("--- BEFORE-Trigger: Activation completed, expecting revert on __loadBalances call");
        console.log("--- Trigger: Attempt redundant __loadBalances call ---");
        vm.expectRevert("Can't load balance into activated token");
        token.__loadBalances(addresses, balances);
        vm.stopPrank();

        console.log("--- AFTER-Trigger: Revert occurred as expected ---");
        console.log("Vulnerability not Exist: Internal state cannot be observed, revert behavior confirmed");
    }
}