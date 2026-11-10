// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.2;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract CoinTokenGasTest is Test {
    CoinToken token;
    address owner;
    address feeAddress = address(0x123);

    function setUp() public {
        owner = address(this);
        token = new CoinToken(
            "TestToken",
            "TTK",
            18,
            1000000000 * (10**18),  // Supply in base units
            1,  // txFee
            1,  // burnFee
            1,  // charityFee
            feeAddress,
            owner
        );
    }

    function test_GasCostIncreaseForBalanceOfAfterExclusions() public {
        // Before-trigger measurement
        emit log("--- BEFORE-Trigger balanceOf ---");
        uint256 gasBefore = gasleft();
        token.balanceOf(owner);
        uint256 initialGasUsed = gasBefore - gasleft();
        emit log_named_uint("Gas used without exclusions", initialGasUsed);

        // Critical trigger action
        emit log("--- Trigger: Excluding 300 accounts ---");
        for (uint256 i = 0; i < 300; i++) {
            address account = address(uint160(0x1000 + i));
            token.excludeAccount(account);
        }

        // After-trigger measurement
        emit log("--- AFTER-Trigger balanceOf ---");
        gasBefore = gasleft();
        token.balanceOf(owner);
        uint256 finalGasUsed = gasBefore - gasleft();
        emit log_named_uint("Gas used with 300 exclusions", finalGasUsed);

        // Vulnerability determination
        if (finalGasUsed > initialGasUsed * 2) {
            emit log("Vulnerability Exists: Gas consumption increased to more than twice after exclusions");
        } else {
            emit log("Vulnerability not Exist: Gas consumption remained within acceptable limits");
        }
    }
}