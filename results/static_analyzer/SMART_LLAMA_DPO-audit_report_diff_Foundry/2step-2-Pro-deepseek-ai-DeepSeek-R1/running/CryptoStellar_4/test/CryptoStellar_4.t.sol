// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CryptoStellar.sol";

contract PrivilegeEscalationTest is Test {
    CryptoStellar token;
    address owner = address(0x1);
    address nonOwner = address(0x2);
    address maliciousWallet = address(0xBAD);

    function setUp() public {
        // Mock Uniswap calls to avoid deployment errors
        address routerAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        vm.etch(routerAddr, new bytes(0x1)); // Create mock router
        
        // Mock router calls
        vm.mockCall(
            routerAddr,
            abi.encodeWithSelector(bytes4(keccak256("factory()"))),
            abi.encode(address(0xcafe))
        );
        vm.mockCall(
            routerAddr,
            abi.encodeWithSelector(bytes4(keccak256("WETH()"))),
            abi.encode(address(0xdead))
        );
        vm.mockCall(
            address(0xcafe),
            abi.encodeWithSelector(bytes4(keccak256("createPair(address,address)"))),
            abi.encode(address(0xdeed))
        );

        // Deploy token as the owner
        vm.startPrank(owner);
        token = new CryptoStellar();
        vm.stopPrank();
    }

    // Helper function to read team wallet from storage slot 1
    function readTeamWallet() internal view returns (address) {
        bytes32 slot = bytes32(uint256(1)); // slot 1 after Ownable (slot 0)
        bytes32 data = vm.load(address(token), slot);
        return address(uint160(uint256(data)));
    }

    function testNonOwnerCannotChangeTeamWallet() public {
        // Check initial team wallet
        console.log("--- BEFORE-Trigger setTeamWallet (nonOwner) ---");
        address priorWallet = readTeamWallet();
        console.log("Prior Team Wallet: %s", priorWallet);

        console.log("--- Trigger setTeamWallet (nonOwner attempts) ---");
        vm.prank(nonOwner);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setTeamWalletAddress(maliciousWallet);

        console.log("--- AFTER-Trigger setTeamWallet (nonOwner) ---");
        address afterWallet = readTeamWallet();
        console.log("After Team Wallet: %s", afterWallet);

        // Validate state unchanged
        if (afterWallet == priorWallet) {
            console.log("Vulnerability not Exists: Team wallet unchanged by non-owner as expected");
        } else {
            console.log("Vulnerability Exists: Team wallet altered by non-owner");
        }
    }

    function testOwnerCanChangeTeamWallet() public {
        // Check initial team wallet
        console.log("--- BEFORE-Trigger setTeamWallet (owner) ---");
        address priorWallet = readTeamWallet();
        console.log("Prior Team Wallet: %s", priorWallet);

        console.log("--- Trigger setTeamWallet (owner) ---");
        vm.prank(owner);
        token.setTeamWalletAddress(maliciousWallet);

        console.log("--- AFTER-Trigger setTeamWallet (owner) ---");
        address afterWallet = readTeamWallet();
        console.log("After Team Wallet: %s", afterWallet);

        // Validate state changed
        if (afterWallet == maliciousWallet) {
            console.log("Vulnerability not Exist: Team wallet changed by owner as expected");
        } else {
            console.log("Vulnerability Exists: Team wallet not updated by owner");
        }
    }
}