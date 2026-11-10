// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SHIBASOCCERLEAGUE.sol";

contract SHIBASOCCERLEAGUE_Test is Test {
    SHIBASOCCERLEAGUE token;
    address public owner = vm.addr(1);
    address public addr2 = vm.addr(2);
    address[] private addresses;
    uint256[] private tokens;

    function setUp() public {
        // Define the actual router address from the contract
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address fakeWETH = address(0x20);
        address fakeFactory = address(0x30);
        address fakePair = address(0x40);

        // Mock external contract calls
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("WETH()"),
            abi.encode(fakeWETH)
        );
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("factory()"),
            abi.encode(fakeFactory)
        );
        vm.mockCall(
            fakeFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(fakePair)
        );

        // Deploy contract as owner
        vm.startPrank(owner);
        token = new SHIBASOCCERLEAGUE();
        vm.stopPrank();
    }

    function test_ArraysExceedingMaxLength() public {
        // Create arrays with 501 elements
        addresses = new address[](501);
        tokens = new uint256[](501);

        for (uint256 i = 0; i < 501; i++) {
            addresses[i] = vm.addr(i + 100);
            tokens[i] = 1;
        }

        vm.startPrank(owner);
        // All calls should revert due to array size
        vm.expectRevert("GAS Error: max limit is 500 addresses");
        token.manage_FeeExempt(addresses, true);

        vm.expectRevert("GAS Error: max limit is 500 addresses");
        token.manage_TxLimitExempt(addresses, true);

        vm.expectRevert("GAS Error: max limit is 500 addresses");
        token.manage_WalletLimitExempt(addresses, true);

        vm.expectRevert("GAS Error: max limit is 500 addresses");
        token.bulksend(addresses, tokens);
        vm.stopPrank();

        // Final vulnerability verdict
        console.log("Vulnerability not Exist: Arrays exceeding max length caused reverts as expected");
    }

    function test_ArraysWithinMaxLength() public {
        // Create arrays with 500 elements
        addresses = new address[](500);
        tokens = new uint256[](500);

        for (uint256 i = 0; i < 500; i++) {
            addresses[i] = vm.addr(i + 100);
            tokens[i] = 1;
        }

        vm.startPrank(owner);
        // All calls should succeed
        token.manage_FeeExempt(addresses, true);
        token.manage_TxLimitExempt(addresses, true);
        token.manage_WalletLimitExempt(addresses, true);
        token.bulksend(addresses, tokens);
        vm.stopPrank();
    }

    function test_BulkSendBalanceCheck() public {
        addresses = new address[](2);
        tokens = new uint256[](2);
        addresses[0] = addr2;
        
        // Get owner balance and set invalid transfer amount
        tokens[0] = token.balanceOf(owner) + 1;
        tokens[1] = 1;

        vm.startPrank(owner);
        // Should revert due to insufficient balance
        vm.expectRevert("Not enough tokens in wallet");
        token.bulksend(addresses, tokens);
        vm.stopPrank();
    }
}