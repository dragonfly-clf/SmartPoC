// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GoatWolf.sol";

contract FailingERC20 {
    mapping(address => uint256) public balanceOf;

    function setBalance(address account, uint256 amount) external {
        balanceOf[account] = amount;
    }

    // Always fail transfer by returning false
    function transfer(address, uint256) external pure returns (bool) {
        return false;
    }
}

contract GoatWolfTokenTest is Test {
    GoatWolf public token;
    address constant ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant OWNER = address(0x123);

    function setUp() public {
        // Mock router responses
        vm.mockCall(
            ROUTER_ADDR,
            abi.encodeWithSignature("factory()"),
            abi.encode(address(0x123)) // Mock factory address
        );
        vm.mockCall(
            ROUTER_ADDR,
            abi.encodeWithSignature("WETH()"),
            abi.encode(address(0x456)) // Mock WETH address
        );
        // Mock factory response
        vm.mockCall(
            address(0x123),
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(address(0x789)) // Mock pair address
        );

        // Deploy token contract
        token = new GoatWolf();

        // Transfer ownership to designated OWNER
        token.transferOwnership(OWNER);
    }

    function test_ERC20TransferFailure() public {
        FailingERC20 failingToken = new FailingERC20();
        failingToken.setBalance(address(token), 100 ether);

        console.log("--- BEFORE-Trigger ---");
        // Record initial state
        uint256 contractBalanceBefore = failingToken.balanceOf(address(token));
        uint256 ownerBalanceBefore = failingToken.balanceOf(OWNER);
        console.log("Contract balance (before):", contractBalanceBefore);
        console.log("Owner balance (before):", ownerBalanceBefore);

        console.log("--- Trigger ClaimStuckTokens ---");
        // Perform claim operation - should not revert but transfer fails
        vm.prank(OWNER);
        token.claimStuckTokens(address(failingToken));

        console.log("--- AFTER-Trigger ---");
        // Check post-trigger balance
        uint256 contractBalanceAfter = failingToken.balanceOf(address(token));
        uint256 ownerBalanceAfter = failingToken.balanceOf(OWNER);
        console.log("Contract balance (after):", contractBalanceAfter);
        console.log("Owner balance (after):", ownerBalanceAfter);

        // Vulnerability verification
        bool stateUnchanged = (contractBalanceAfter == contractBalanceBefore) 
                           && (ownerBalanceAfter == ownerBalanceBefore);
        
        if (stateUnchanged) {
            console.log("Vulnerability Exists: Failed token transfer did not revert and balances remain unchanged");
        } else {
            console.log("Vulnerability not Exist: Transfer failure caused state change");
        }
    }

    function test_EthTransfer() public {
        // Send ETH to token contract
        payable(address(token)).transfer(1 ether);
        uint256 initialOwnerBalance = OWNER.balance;

        // Verify initial ETH balance
        assertEq(address(token).balance, 1 ether, "Initial token ETH balance mismatch");

        // Claim ETH
        vm.prank(OWNER);
        token.claimStuckTokens(address(0));

        // Validate ETH transfer
        assertEq(address(token).balance, 0, "Token ETH not drained");
        assertEq(OWNER.balance, initialOwnerBalance + 1 ether, "Owner didn't receive ETH");
    }
}