// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ELONPETS.sol";

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0xBEEF);
    }
}

contract MockRouter {
    address public factory;
}

contract GasLimitTest is Test {
    ELONPETS token;
    address owner = address(0xBEEF);

    function setUp() public {
        vm.startPrank(owner);
        
        // Deploy real MockFactory
        MockFactory mockFactory = new MockFactory();
        address routerAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        
        // Properly initialize MockRouter storage
        vm.etch(routerAddress, type(MockRouter).runtimeCode);
        vm.store(
            routerAddress,
            bytes32(0),
            bytes32(abi.encode(address(mockFactory)))
        );

        // Deploy token contract now that router is properly initialized
        token = new ELONPETS();
        vm.stopPrank();
    }

    function testValidManageBlacklist() public {
        address[] memory addresses = new address[](200);
        for (uint256 i = 0; i < addresses.length; i++) {
            addresses[i] = address(uint160(uint256(keccak256(abi.encode(i)))));
        }

        console.log("--- BEFORE Trigger ---");
        console.log("Preparing to call manage_blacklist with 200 addresses");

        console.log("--- Trigger Operation ---");
        vm.prank(owner);
        token.manage_blacklist(addresses, false);

        console.log("--- AFTER Trigger ---");
        console.log("Transaction successfully processed without revert");
        console.log("Vulnerability not Exist: Function call with 200 addresses completed without exceeding gas limits");
    }

    function testExceedMaxAddressLimit() public {
        address[] memory addresses = new address[](201);
        for (uint256 i = 0; i < addresses.length; i++) {
            addresses[i] = address(uint160(uint256(keccak256(abi.encode(i)))));
        }

        console.log("--- BEFORE Trigger ---");
        console.log("Preparing to call manage_blacklist with 201 addresses");
        console.log("Expecting revert: 'GAS Error: max limit is 200 addresses'");

        console.log("--- Trigger Operation ---");
        vm.prank(owner);
        vm.expectRevert("GAS Error: max limit is 200 addresses");
        token.manage_blacklist(addresses, false);

        console.log("--- AFTER Trigger ---");
        console.log("Transaction reverted as expected");
        console.log("Vulnerability not Exist: Max address limit enforcement prevents excessive gas consumption");
    }
}