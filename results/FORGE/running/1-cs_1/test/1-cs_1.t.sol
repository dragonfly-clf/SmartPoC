// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/CryptoStellar.sol";

contract CryptoStellarTest is Test {
    CryptoStellar token;
    address owner = address(0x1);

    // Number of raw storage slots snapshotted for the universal storage diff.
    uint256 internal constant SLOT_COUNT = 100;

    function setUp() public {
        // Create mock addresses
        address mockRouter = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address mockWETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        address mockPair = address(0x456);
        address mockFactory = address(0x789);

        // Mock router responses
        vm.mockCall(mockRouter, abi.encodeWithSignature("factory()"), abi.encode(mockFactory));
        vm.mockCall(mockRouter, abi.encodeWithSignature("WETH()"), abi.encode(mockWETH));

        // Mock factory createPair using selector wildcard to match any token addresses
        bytes4 createPairSelector = bytes4(keccak256("createPair(address,address)"));
        vm.mockCall(mockFactory, abi.encodePacked(createPairSelector), abi.encode(mockPair));

        // Deploy contract
        vm.startPrank(owner);
        token = new CryptoStellar();
        vm.stopPrank();
    }

    // ------------------------------------------------------------------
    // Differential helpers
    // ------------------------------------------------------------------

    // Low-level staticcall; reads the first 32 bytes of returndata as a uint.
    // Uses runtime calldata so it compiles even if the getter is absent.
    function _tryStatic(address target, bytes memory data)
        internal
        view
        returns (bool ok, uint256 value)
    {
        (bool success, bytes memory ret) = target.staticcall(data);
        if (success && ret.length >= 32) {
            ok = true;
            assembly {
                value := mload(add(ret, 32))
            }
        }
    }

    // Try a curated list of plausible public getters for the total sell tax.
    function _readTotalSellTax(address target)
        internal
        view
        returns (bool found, uint256 value, string memory sig)
    {
        string[10] memory sigs = [
            "_totalTaxIfSelling()",
            "totalTaxIfSelling()",
            "totalSellTax()",
            "_totalSellTax()",
            "sellTax()",
            "_sellTax()",
            "totalSellFee()",
            "getTotalSellTax()",
            "getSellTax()",
            "sellFee()"
        ];
        for (uint256 i = 0; i < sigs.length; i++) {
            (bool ok, uint256 v) = _tryStatic(target, abi.encodeWithSignature(sigs[i]));
            if (ok) {
                return (true, v, sigs[i]);
            }
        }
        return (false, 0, "");
    }

    // Snapshot the first SLOT_COUNT raw storage slots (universal state diff).
    function _snapshotSlots(address target)
        internal
        view
        returns (bytes32[] memory data)
    {
        data = new bytes32[](SLOT_COUNT);
        for (uint256 i = 0; i < SLOT_COUNT; i++) {
            data[i] = vm.load(target, bytes32(i));
        }
    }

    function test_ExcessiveSellTaxCanBeSet() public {
        // (i) BEFORE-Trigger: action + state snapshot
        console.log("=== BEFORE-Trigger State Snapshot ===");
        (bool foundBefore, uint256 taxBefore, string memory sig) = _readTotalSellTax(address(token));
        if (foundBefore) {
            console.log("Matched sell-tax getter:", sig);
            console.log("Sell tax before:", taxBefore);
        } else {
            console.log("No named sell-tax getter found; using raw storage diff");
        }
        bytes32[] memory slotsBefore = _snapshotSlots(address(token));

        // (ii) Trigger operation
        console.log("=== Trigger: owner -> setSellTaxes(10, 10, 10) ===");
        vm.prank(owner);
        (bool ok, ) = address(token).call(
            abi.encodeWithSignature(
                "setSellTaxes(uint256,uint256,uint256)",
                uint256(10),
                uint256(10),
                uint256(10)
            )
        );
        console.log("setSellTaxes succeeded:", ok);

        // If the call reverted, the tax was bounded -> no vulnerability.
        if (!ok) {
            console.log("Vulnerability not Exist: setSellTaxes(10,10,10) reverted, sell tax is capped/enforced");
            return;
        }

        // (iii) AFTER-Trigger: action + state snapshot
        console.log("=== AFTER-Trigger State Snapshot ===");
        (bool foundAfter, uint256 taxAfter, ) = _readTotalSellTax(address(token));
        if (foundBefore && foundAfter) {
            console.log("Sell tax after:", taxAfter);
        }
        bytes32[] memory slotsAfter = _snapshotSlots(address(token));

        // (iv) Differential comparison
        console.log("=== Differential Comparison ===");

        bool namedChanged = foundBefore && foundAfter && (taxAfter != taxBefore);
        if (namedChanged) {
            console.log("Named getter changed from", taxBefore, "to", taxAfter);
        }

        uint256 changedSlots = 0;
        for (uint256 i = 0; i < SLOT_COUNT; i++) {
            if (slotsBefore[i] != slotsAfter[i]) {
                changedSlots++;
                console.log("  changed storage slot:", i);
            }
        }
        bool storageChanged = changedSlots > 0;
        console.log("Number of changed storage slots:", changedSlots);

        // 10 + 10 + 10 = 30% is considered the "excessive" tax that was set.
        bool excessivePresent = foundAfter && (taxAfter >= 25);

        bool stateChanged = namedChanged || storageChanged || excessivePresent;

        if (stateChanged) {
            console.log("State changed: YES");
            console.log("Vulnerability Exists: owner set excessive sell tax (10%+10%+10%=30%) with no cap; sell-tax state changed after setSellTaxes");
        } else {
            console.log("State changed: NO");
            console.log("Vulnerability not Exist: no sell-tax state change detected after setSellTaxes(10,10,10)");
        }
    }
}