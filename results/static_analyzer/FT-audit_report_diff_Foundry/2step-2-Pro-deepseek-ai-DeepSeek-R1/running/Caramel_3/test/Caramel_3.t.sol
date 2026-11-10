// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Caramel.sol";

contract CaramelTest is Test {
    Caramel public token;
    address private owner = address(1);
    address private alice = address(2);

    function setUp() public {
        vm.prank(owner);
        token = new Caramel();
    }

    function test_mint_arbitrary_amount() public {
        uint256 initialSupply = token.totalSupply();
        uint256 ownerInitialBalance = token.balanceOf(owner);
        uint256 arbitraryAmount = 1e30; // Very large mint amount

        emit log("--- BEFORE-Trigger State ---");
        emit log_named_uint("Initial total supply: ", initialSupply);
        emit log_named_uint("Owner initial balance: ", ownerInitialBalance);
        emit log_named_uint("Trigger Action: Mint", arbitraryAmount);

        vm.startPrank(owner);
        token.mint(arbitraryAmount);
        vm.stopPrank();

        emit log("--- AFTER-Trigger State ---");
        uint256 newTotalSupply = token.totalSupply();
        uint256 ownerNewBalance = token.balanceOf(owner);
        emit log_named_uint("New total supply: ", newTotalSupply);
        emit log_named_uint("Owner new balance: ", ownerNewBalance);

        uint256 supplyIncreased = newTotalSupply - initialSupply;
        uint256 balanceIncreased = ownerNewBalance - ownerInitialBalance;

        bool vulnerabilityExists = (supplyIncreased == arbitraryAmount) && 
                                   (balanceIncreased == arbitraryAmount);

        if (vulnerabilityExists) {
            emit log("Vulnerability Exists: Owner successfully minted arbitrary amount without restrictions");
        } else {
            emit log("Vulnerability not Exist: State changes do not match expected mint behavior");
        }

        // Original assertions
        assertEq(token.totalSupply(), initialSupply + arbitraryAmount);
        assertEq(token.balanceOf(owner), ownerInitialBalance + arbitraryAmount);
    }

    function test_nonowner_cannot_mint() public {
        uint256 initialSupply = token.totalSupply();

        vm.prank(alice);
        vm.expectRevert("Ownable: caller is not the owner");
        token.mint(1e18);

        assertEq(token.totalSupply(), initialSupply);
    }
}