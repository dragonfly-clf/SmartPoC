// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Guitarist.sol";

contract GuitaristTest is Test {
    Guitarist guitarist;
    address owner = address(0x1);

    function setUp() public {
        vm.startPrank(owner);
        // Deploy contract without triggering initial mints
        guitarist = new Guitarist("init_uri", "contract_uri");
        // Set wallets to avoid reverts (required for contract setup)
        guitarist.setWallet2(address(0x2));
        guitarist.setWallet3(address(0x3));
        vm.stopPrank();
    }

    // Safely read MAX_SUPPLY if the getter is exposed; returns (value, found)
    function _readMaxSupply() internal view returns (uint256 value, bool found) {
        (bool ok, bytes memory data) =
            address(guitarist).staticcall(abi.encodeWithSignature("MAX_SUPPLY()"));
        if (ok && data.length >= 32) {
            return (abi.decode(data, (uint256)), true);
        }
        return (0, false);
    }

    function testAirdropExceedsMaxSupply() public {
        // ============================================================
        // (i) PRE-TRIGGER: state snapshot
        // ============================================================
        console.log("=== [1] BEFORE Trigger: State Snapshot ===");
        uint256 supplyBefore = guitarist.totalSupply();
        (uint256 maxSupply, bool hasMax) = _readMaxSupply();
        console.log("totalSupply before airdrop:", supplyBefore);
        if (hasMax) {
            console.log("MAX_SUPPLY cap:", maxSupply);
        } else {
            console.log("MAX_SUPPLY cap: (getter not exposed)");
        }

        // Choose an airdrop amount that would breach the cap
        uint256 mintAmount;
        if (hasMax) {
            if (maxSupply >= supplyBefore) {
                mintAmount = maxSupply - supplyBefore + 1; // exceed the cap by 1
            } else {
                mintAmount = 1; // already at / above the cap
            }
        } else {
            mintAmount = 1_000_000_000 * 1e18; // fallback: very large amount
        }
        console.log("Airdrop mint amount:", mintAmount);

        address[] memory receivers = new address[](1);
        receivers[0] = address(0x1234); // Arbitrary receiver
        uint256[] memory quantities = new uint256[](1);
        quantities[0] = mintAmount;

        // ============================================================
        // (ii) TRIGGER: call airdrop()
        // ============================================================
        console.log("=== [2] TRIGGER: airdrop(receivers, quantities) ===");
        bool airdropSucceeded;
        vm.startPrank(owner);
        try guitarist.airdrop(receivers, quantities) {
            airdropSucceeded = true;
            console.log("airdrop() SUCCEEDED (no MAX_SUPPLY revert)");
        } catch {
            airdropSucceeded = false;
            console.log("airdrop() REVERTED (cap apparently enforced)");
        }
        vm.stopPrank();

        // ============================================================
        // (iii) POST-TRIGGER: state snapshot
        // ============================================================
        console.log("=== [3] AFTER Trigger: State Snapshot ===");
        uint256 supplyAfter = guitarist.totalSupply();
        console.log("totalSupply after airdrop:", supplyAfter);
        if (hasMax) {
            console.log("MAX_SUPPLY cap:", maxSupply);
        }
        uint256 delta = supplyAfter >= supplyBefore ? supplyAfter - supplyBefore : 0;
        console.log("totalSupply delta:", delta);

        // ============================================================
        // (iv) DIFFERENTIAL COMPARISON VERDICT
        // ============================================================
        console.log("=== [4] DIFFERENTIAL COMPARISON VERDICT ===");
        bool supplyChanged = supplyAfter != supplyBefore;
        bool exceedsCap = hasMax ? (supplyAfter > maxSupply) : false;
        console.log("State changed (totalSupply)?", supplyChanged);
        if (hasMax) {
            console.log("totalSupply > MAX_SUPPLY?", exceedsCap);
        }

        if (airdropSucceeded && supplyChanged && (!hasMax || exceedsCap)) {
            if (hasMax) {
                console.log(
                    "Vulnerability Exists: airdrop() bypassed MAX_SUPPLY - totalSupply now exceeds the cap"
                );
            } else {
                console.log(
                    "Vulnerability Exists: airdrop() minted with no MAX_SUPPLY enforcement"
                );
            }
        } else {
            console.log(
                "Vulnerability not Exist: totalSupply did not grow beyond MAX_SUPPLY"
            );
        }
    }
}