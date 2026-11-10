// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/YUG.sol";

contract YUGPrivilegeEscalationTest is Test {
    YUG token;
    address admin = address(0x1);
    address newAdmin = address(0x2);

    // Correct checksummed addresses (using case-insensitive addresses doesn't work)
    address constant ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant FACTORY_ADDR = 0x000000000000000000000000000000000000cafE;
    address constant WETH_ADDR = 0x000000000000000000000000000000000000bEEF;
    address constant PAIR_ADDR = 0x000000000000000000000000000000000000dEaD;

    function setUp() public {
        // Create mock Uniswap router and factory
        deployMocks();

        // Deploy token contract as admin
        vm.startPrank(admin);
        token = new YUG();
        vm.stopPrank();
    }

    function deployMocks() private {
        // Minimal router implementation that returns fixed addresses
        bytes memory routerCode = abi.encodePacked(
            hex"608060405234801561001057600080fd5b5060e08061001f6000396000f3fe",
            abi.encode(FACTORY_ADDR),
            abi.encode(uint256(0)),
            abi.encode(WETH_ADDR)
        );
        vm.etch(ROUTER_ADDR, routerCode);

        // Minimal factory implementation that returns pair address
        bytes memory factoryCode = abi.encodePacked(
            hex"608060405234801561001057600080fd5b5060c58061001f6000396000f3fe",
            abi.encode(PAIR_ADDR)
        );
        vm.etch(FACTORY_ADDR, factoryCode);
    }

    function test_arbitrary_ownership_transfer() public {
        emit log("--- BEFORE-Trigger Owner ---");
        address initialOwner = token.owner();
        emit log_named_address("Initial contract owner", initialOwner);
        
        emit log("--- Trigger transferOwnership ---");
        // Admin transfers ownership to newAdmin
        vm.prank(admin);
        token.transferOwnership(newAdmin);
        
        emit log("--- AFTER-Trigger Owner ---");
        address finalOwner = token.owner();
        emit log_named_address("Final contract owner", finalOwner);
        
        if (finalOwner == newAdmin) {
            emit log("Vulnerability Exists: Ownership changed arbitrarily without restrictions");
        } else {
            emit log("Vulnerability not Exist: Ownership remains unchanged");
        }

        // Verify ownership was transferred without restrictions
        assertEq(token.owner(), newAdmin, "Ownership not transferred");
    }
}