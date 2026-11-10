// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DUZU_Coin.sol";

contract BadToken {
    function transfer(address, uint256) external pure returns (bool) {
        return false;
    }
}

contract DUZU_CoinTest is Test {
    DUZU_Coin public token;
    BadToken public badToken;
    address constant DUZU_TARGET = address(0x1234);
    
    function setUp() public {
        token = new DUZU_Coin(
            DUZU_TARGET,
            "Test Token",
            "TST",
            18,
            1000 * 10 ** 18
        );
        badToken = new BadToken();
    }

    function test_recoverTokenIgnoresTransferFailure() public {
        console.log("--- BEFORE-Trigger RecoverToken ---");
        // Validate test contract is owner (required for recoverToken)
        assertEq(token.owner(), address(this));
        console.log("Owner confirmed: %s", address(this));

        console.log("--- Trigger RecoverToken ---");
        // Track call success status
        bool callSuccess;

        try token.recoverToken(address(badToken), 1 ether) {
            callSuccess = true;
        } catch {
            callSuccess = false;
        }

        console.log("--- AFTER-Trigger RecoverToken ---");
        console.log("Call status:", callSuccess ? "Success no revert" : "Reverted");
        
        // Final vulnerability verdict
        if (callSuccess) {
            console.log("Vulnerability Exists: recoverToken ignores transfer failure without reverting");
        } else {
            console.log("Vulnerability not Exist: recoverToken reverts on failed transfer as expected");
        }
    }
}