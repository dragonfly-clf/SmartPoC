// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/parity_wallet_bug_1.sol";

contract ParityWalletBugTest is Test {
    Wallet public wallet;
    address[] public owners;
    uint256 required;
    uint256 daylimit;

    function setUp() public {
        required = 1;
        daylimit = 1 ether;
        owners.push(address(this)); // Push a valid non-zero address
        wallet = new Wallet(owners, required, daylimit);
    }

    function testUninitializedOwners() public {
        // Single state query since differential checks are not applicable
        address ownerAtIndex0 = wallet.getOwner(0);
        
        // Verdict based on query result
        if (ownerAtIndex0 == address(0)) {
            console.log("Vulnerability Exists: getOwner(0) returns address(0) indicating uninitialized storage despite setting an owner");
        } else {
            console.log("Vulnerability not Exist: getOwner(0) returns non-zero address showing proper initialization");
        }
    }
}