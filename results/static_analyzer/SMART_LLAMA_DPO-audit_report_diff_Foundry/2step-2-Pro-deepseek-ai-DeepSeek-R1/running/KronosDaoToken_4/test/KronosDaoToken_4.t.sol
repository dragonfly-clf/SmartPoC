// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KronosDaoToken.sol";

contract MockPinkAntiBot {
    function onPreTransferCheck(address, address, uint256) external pure {}
    function setTokenOwner(address) external pure {}
}

contract KronosDaoTokenPrivilegeTest is Test {
    KronosDaoToken token;
    MockPinkAntiBot mockAntiBot;
    address constant OWNER = address(0x1234);
    address constant NEW_VAULT = address(0x5678);
    address constant ATTACKER = address(0x9999);

    function setUp() public {
        mockAntiBot = new MockPinkAntiBot();
        vm.startPrank(OWNER);
        token = new KronosDaoToken(address(mockAntiBot));
        vm.stopPrank();
    }

    function test_owner_can_change_vault_to_arbitrary_address() public {
        console.log("--- BEFORE-Trigger Vault Change ---");
        address preVault = token.vault();
        console.log("Current vault address:", preVault);

        console.log("--- Trigger setVault ---");
        vm.prank(OWNER);
        token.setVault(NEW_VAULT);

        console.log("--- AFTER-Trigger Vault Change ---");
        address postVault = token.vault();
        console.log("New vault address:", postVault);
        
        bool vaultChanged = (preVault != postVault);
        console.log("Vault changed:", vaultChanged ? "YES" : "NO");
        assertEq(postVault, NEW_VAULT);
    }

    function test_owner_can_disable_antiBot_protection() public {
        console.log("--- BEFORE-Trigger AntiBot ---");
        bool preAntiBotStatus = token.antiBotEnabled();
        console.log("Anti-bot protection enabled (before):", preAntiBotStatus);

        console.log("--- Trigger setEnableAntiBot ---");
        vm.prank(OWNER);
        token.setEnableAntiBot(false);

        console.log("--- AFTER-Trigger AntiBot ---");
        bool postAntiBotStatus = token.antiBotEnabled();
        console.log("Anti-bot protection enabled (after):", postAntiBotStatus);
        
        bool protectionDisabled = (preAntiBotStatus && !postAntiBotStatus);
        console.log("Anti-bot protection disabled:", protectionDisabled ? "YES" : "NO");
        assertFalse(postAntiBotStatus, "Anti-bot protection should be disabled after owner action");
    }

    function test_attacker_cannot_set_vault() public {
        vm.prank(ATTACKER);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setVault(ATTACKER);
    }

    function test_attacker_cannot_disable_antiBot() public {
        vm.prank(ATTACKER);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setEnableAntiBot(false);
    }
}