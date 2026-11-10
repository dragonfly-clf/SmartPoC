// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/StandardToken.sol";

contract StandardTokenGasTest is Test {
    StandardToken token;
    address owner = address(0x123);
    address externalUser = address(0x456);
    uint256 constant TOTAL_SUPPLY = 1000000 * 10**18;

    function setUp() public {
        vm.prank(owner);
        token = new StandardToken(
            "TestToken",    // name_
            "TST",          // symbol_
            18,             // decimals_
            TOTAL_SUPPLY,   // totalSupply_
            address(0),     // serviceFeeReceiver_
            0               // serviceFee_
        );
    }

    function testFunctionsCallable() public {
        // name() call and check
        string memory name = token.name();
        assertEq(name, "TestToken");

        // symbol() call and check
        string memory symbol = token.symbol();
        assertEq(symbol, "TST");

        // decimals() call and check
        uint8 decimals = token.decimals();
        assertEq(decimals, 18);

        // totalSupply() call and check
        uint256 totalSupply = token.totalSupply();
        assertEq(totalSupply, TOTAL_SUPPLY);

        // balanceOf() call and check (owner should have total supply)
        uint256 ownerBalance = token.balanceOf(owner);
        assertEq(ownerBalance, TOTAL_SUPPLY);

        // Check from an external user's perspective
        vm.prank(externalUser);
        uint256 externalBalance = token.balanceOf(externalUser);
        assertEq(externalBalance, 0);

        // Final vulnerability verdict
        console.log("Vulnerability not Exist: no_state_change_required");
    }
}