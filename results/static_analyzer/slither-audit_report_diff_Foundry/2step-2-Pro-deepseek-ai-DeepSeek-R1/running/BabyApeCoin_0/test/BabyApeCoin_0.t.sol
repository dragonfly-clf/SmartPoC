// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BabyApeCoin.sol";

contract BabyApeCoinTest is Test {
    BabyApeCoin token;
    address owner;
    address recipient;

    function setUp() public {
        token = new BabyApeCoin();
        owner = token.owner();
        recipient = address(0xCAFE);
        vm.deal(owner, 1 ether);
    }

    // This test demonstrates the unchecked-transfer vulnerability
    function test_TransferBabyApeByOwner_IgnoresReturnValue() public {
        // Fund contracts with tokens
        uint256 amount = 1000 * 10**18;
        vm.prank(owner);
        token.mint(address(token), amount);  // Mint tokens to contract itself

        // Record balances BEFORE
        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 contractBalanceBefore = token.balanceOf(address(token));
        uint256 recipientBalanceBefore = token.balanceOf(recipient);
        console.log("Contract balance before transfer:", contractBalanceBefore);
        console.log("Recipient balance before transfer:", recipientBalanceBefore);

        // Mock transfer to fail by exceeding allowance mechanism
        vm.mockCall(
            address(token),
            abi.encodeWithSignature("transfer(address,uint256)", recipient, amount),
            abi.encode(false)
        );

        // Execute the function - it should NOT revert despite failed transfer
        console.log("--- Trigger transferBabyApeByOwner ---");
        vm.prank(owner);
        token.transferBabyApeByOwner(recipient, amount);

        // Record balances AFTER
        console.log("--- AFTER-Trigger Transfer ---");
        uint256 contractBalanceAfter = token.balanceOf(address(token));
        uint256 recipientBalanceAfter = token.balanceOf(recipient);
        console.log("Contract balance after transfer:", contractBalanceAfter);
        console.log("Recipient balance after transfer:", recipientBalanceAfter);

        // Check state changes
        bool balancesUnchanged = 
            (contractBalanceBefore == contractBalanceAfter) && 
            (recipientBalanceBefore == recipientBalanceAfter);
        console.log("Balances unchanged:", balancesUnchanged ? "YES" : "NO");
        
        // Vulnerability verdict
        if (balancesUnchanged) {
            console.log("Vulnerability Exists: Transfer failed silently without reverting");
        } else {
            console.log("Vulnerability not Exist: Transfer modified token balances");
        }

        // Check token balances remain unchanged (transfer failed silently)
        assertEq(token.balanceOf(address(token)), amount);
        assertEq(token.balanceOf(recipient), 0);
    }

    // Demonstrate valid transfers for comparison
    function test_TransferBabyApeByOwner_SuccessCase() public {
        uint256 amount = 1000 * 10**18;
        vm.prank(owner);
        token.mint(address(token), amount);

        // Execute valid transfer
        uint256 initialBalance = token.balanceOf(address(token));
        vm.prank(owner);
        token.transferBabyApeByOwner(recipient, amount);

        // Verify state changes
        assertEq(token.balanceOf(address(token)), initialBalance - amount);
        assertEq(token.balanceOf(recipient), amount);
    }
}