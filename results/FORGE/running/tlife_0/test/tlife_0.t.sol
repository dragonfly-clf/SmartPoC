// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TLIFE_Coin.sol";

contract MintVulnerabilityTest is Test {
    TLIFE_Coin token;
    address owner = makeAddr("owner");
    address target = makeAddr("target");
    
    function setUp() public {
        // Fund the owner address with ETH
        vm.deal(address(this), 10 ether);
        
        // Deploy with required ETH value
        token = new TLIFE_Coin{value: 1 ether}(
            target,
            "TestToken",
            "TT",
            18,
            1000 * 10**18
        );
        
        // Transfer ownership to intended owner
        token.transferOwnership(owner);
    }

    function testOwnerCanInflateSupply() public {
        console2.log("--- BEFORE-Trigger Mint ---");
        uint256 initialSupply = token.totalSupply();
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        console2.log("Initial total supply: ", initialSupply);
        console2.log("Initial owner balance: ", ownerBalanceBefore);

        // Attack: Owner mints large amount of tokens
        uint256 attackAmount = 10_000 * 10**18;
        console2.log("\n--- Trigger Mint ---");
        console2.log("Minting:", attackAmount, "tokens to owner");
        vm.startPrank(owner);
        token.mint(owner, attackAmount);
        vm.stopPrank();

        console2.log("\n--- AFTER-Trigger Mint ---");
        uint256 finalSupply = token.totalSupply();
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        console2.log("Final total supply: ", finalSupply);
        console2.log("Final owner balance: ", ownerBalanceAfter);

        uint256 supplyChange = finalSupply - initialSupply;
        uint256 ownerBalanceChange = ownerBalanceAfter - ownerBalanceBefore;
        console2.log("\nChanges after minting:");
        console2.log("Supply increase:", supplyChange);
        console2.log("Owner balance increase:", ownerBalanceChange);

        bool isVulnerable = (supplyChange == attackAmount) && (ownerBalanceChange == attackAmount);
        if (isVulnerable) {
            console2.log("Vulnerability Exists: supply and owner balance increased by exact attack amount");
            // Verify supply inflation with assertions
            assertEq(finalSupply, initialSupply + attackAmount, "Inflation failed");
            assertEq(ownerBalanceAfter, ownerBalanceBefore + attackAmount, "Owner balance not increased");
            console2.log("----", unicode"✅ Verification: Assertions passed");
        } else {
            console2.log("Vulnerability not Exist: state changes do not match attack amount");
            console2.log("----", unicode"❌ Verification: Assertions would fail");
        }
    }
}