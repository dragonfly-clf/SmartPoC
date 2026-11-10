// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ZeusPet.sol";

contract ZeusPetStateInconsistencyTest is Test {
    ZeusPet public token;
    address public owner = address(this);
    address payable marketingWallet = payable(0x0000000000000000000000000000000000000123);
    address public BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    address alice = makeAddr("alice");
    
    function setUp() public {
        // Deploy with 5% marketing fee, 5% burn fee
        token = new ZeusPet(5, 5, marketingWallet);
    }

    function test_totalSupplyMatchesBalanceSum() public {
        // Log the initial state: total supply and balance sum
        uint256 initialSupply = token.totalSupply();
        uint256 initialBalanceSum = getBalanceSum();

        console.log("--- BEFORE-Trigger State ---");
        console.log("Total Supply: ", initialSupply);
        console.log("BalanceSum (all known addresses): ", initialBalanceSum);
        console.log("State Consistent: ", initialSupply == initialBalanceSum ? "true" : "false");

        console.log("--- Trigger: Transfer ---");
        // Transfer tokens to alice
        uint256 amount = 1000 ether;
        token.transfer(alice, amount);

        // Log state after transfer
        uint256 afterSupply = token.totalSupply();
        uint256 afterBalanceSum = getBalanceSum();

        console.log("--- AFTER-Trigger State ---");
        console.log("Total Supply: ", afterSupply);
        console.log("BalanceSum (all known addresses): ", afterBalanceSum);
        console.log("State Consistent: ", afterSupply == afterBalanceSum ? "true" : "false");
        console.log("State Changed From Initial: ", initialSupply == afterSupply ? 
                   "No (total supply unchanged)" : "Yes (total supply changed)");

        // Final verdict
        if (afterSupply != afterBalanceSum) {
            console.log("Vulnerability Exists: Transfer caused state inconsistency between total supply and balance sum");
        } else {
            console.log("Vulnerability not Exist: State remains consistent between total supply and balance sum");
        }
    }

    // Helper function to get the sum of balances for known addresses
    function getBalanceSum() internal view returns (uint256) {
        return 
            token.balanceOf(owner) +
            token.balanceOf(alice) +
            token.balanceOf(marketingWallet) +
            token.balanceOf(BURN_ADDRESS) +
            token.balanceOf(address(token));
    }
}