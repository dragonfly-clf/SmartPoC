// SPDX-License-Identifier: MIT
pragma solidity 0.6.2;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "../src/BCPToken.sol";

contract BCPTokenTest is Test {
    BCPToken token;
    uint256 constant CAP = 1000 * 10**18;
    address minter = address(0x1);
    address recipient = address(0x2);

    function setUp() public {
        // Deploy token with cap
        token = new BCPToken("BCPToken", "BCP", CAP);

        // Assign minter role
        token.grantRole(token.MINTER_ROLE(), minter);
    }

    function test_CapEnforcedDuringMint() public {
        console.log("--- BEFORE-Trigger Mint (initial state) ---");
        uint256 initialSupply = token.totalSupply();
        uint256 initialCap = token.cap();
        console.log("Initial totalSupply:", initialSupply);
        console.log("Initial cap:", initialCap);
        assertEq(initialCap, CAP, "Initial cap should be set");

        // Mint up to cap
        vm.prank(minter);
        token.mint(recipient, CAP);

        console.log("--- AFTER-Trigger First Mint ---");
        uint256 supplyAfterMint = token.totalSupply();
        console.log("TotalSupply after cap mint:", supplyAfterMint);
        assertEq(supplyAfterMint, CAP, "Supply should reach cap");

        console.log("--- BEFORE-Trigger Excess Mint ---");
        uint256 supplyBeforeExcess = token.totalSupply();
        uint256 capBeforeExcess = token.cap();
        console.log("Supply before excess mint:", supplyBeforeExcess);
        console.log("Cap before excess mint:", capBeforeExcess);

        console.log("--- Trigger Excess Mint Attempt ---");
        vm.expectRevert("ERC20Capped: cap exceeded");
        vm.prank(minter);
        token.mint(recipient, 1);

        console.log("--- AFTER-Trigger Excess Mint ---");
        uint256 supplyAfterExcess = token.totalSupply();
        uint256 capAfterExcess = token.cap();
        console.log("Supply after excess mint:", supplyAfterExcess);
        console.log("Cap after excess mint:", capAfterExcess);

        console.log("--- State Diff Verification ---");
        bool mintSucceeded = (supplyAfterExcess > supplyBeforeExcess);
        if (mintSucceeded) {
            console.log("Vulnerability Exists: Successfully minted beyond cap");
        } else {
            console.log("Vulnerability not Exist: Cap enforcement works correctly");
        }
    }

    function test_CapCannotBeIncreased() public {
        console.log("--- BEFORE-Trigger Cap Change ---");
        uint256 initialCap = token.cap();
        console.log("Initial cap:", initialCap);

        console.log("--- Trigger Cap Change Attempt ---");
        bytes memory payload = abi.encodeWithSignature("cap(uint256)", CAP * 2);
        (bool success, ) = address(token).call(payload);

        console.log("--- AFTER-Trigger Cap Change ---");
        uint256 afterCap = token.cap();
        console.log("Cap after change attempt:", afterCap);

        console.log("--- State Diff Verification ---");
        if (afterCap != initialCap) {
            console.log("Vulnerability Exists: Cap was changed from", initialCap, "to", afterCap);
        } else {
            console.log("Vulnerability not Exist: Cap remains unchanged");
        }

        // Original assertions preserved
        assertFalse(success, "Cap should not be updatable");
        assertEq(afterCap, CAP, "Cap was unexpectedly changed");
    }
}