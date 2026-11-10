// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DEXI.sol";

contract DEXIMintTest is Test {
    DEXI token;
    uint256 constant MAX_SUPPLY_MULTIPLIER = 5;
    uint256 public INITIAL_SUPPLY;
    uint256 public MAX_SUPPLY;
    address constant OWNER = address(1);

    struct Snapshot {
        uint256 supply;
        uint256 ownerBal;
        uint256 yearMinted;
    }

    function setUp() public {
        vm.prank(OWNER);
        token = new DEXI();
        INITIAL_SUPPLY = token.totalSupply();
        MAX_SUPPLY = INITIAL_SUPPLY * MAX_SUPPLY_MULTIPLIER;
    }

    // --- Differential helpers ---
    function _isLeapYear(uint256 year) internal pure returns (bool) {
        return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
    }

    function _getYear(uint256 timestamp) internal pure returns (uint256) {
        uint256 daysSinceEpoch = timestamp / 1 days;
        uint256 year = 1970;
        while (true) {
            uint256 daysInYear = _isLeapYear(year) ? 366 : 365;
            if (daysSinceEpoch < daysInYear) {
                return year;
            }
            daysSinceEpoch -= daysInYear;
            year++;
        }
        return year; // unreachable, added to satisfy compiler
    }

    function _snapshot() internal view returns (Snapshot memory s) {
        s.supply = token.totalSupply();
        s.ownerBal = token.balanceOf(OWNER);
        s.yearMinted = token._yearMintedAmount(uint16(_getYear(block.timestamp)));
    }

    function _logSnapshot(string memory label, Snapshot memory s) internal {
        console.log(label);
        console.log("  totalSupply:", s.supply);
        console.log("  OWNER balance:", s.ownerBal);
        console.log("  yearMintedAmount:", s.yearMinted);
    }

    function _logComparison(
        string memory label,
        Snapshot memory beforeState,
        Snapshot memory afterState
    ) internal {
        bool supplyChanged = afterState.supply != beforeState.supply;
        bool ownerChanged = afterState.ownerBal != beforeState.ownerBal;
        bool yearChanged = afterState.yearMinted != beforeState.yearMinted;

        console.log(label);
        console.log("  totalSupply changed:", supplyChanged ? "YES" : "NO");
        console.log("  OWNER balance changed:", ownerChanged ? "YES" : "NO");
        console.log("  yearMintedAmount changed:", yearChanged ? "YES" : "NO");
        console.log(
            "  state changed:",
            (supplyChanged || ownerChanged || yearChanged) ? "YES" : "NO"
        );
    }

    function _mintAndLog(string memory label, uint256 mintAmount)
        internal
        returns (bool success)
    {
        Snapshot memory beforeState = _snapshot();
        console.log("--- BEFORE-Trigger Mint ---");
        console.log(label);
        _logSnapshot("  state:", beforeState);
        console.log("  mint amount:", mintAmount);

        vm.prank(OWNER);
        (success, ) = address(token).call(
            abi.encodeWithSignature("mint(address,uint256)", OWNER, mintAmount)
        );

        Snapshot memory afterState = _snapshot();
        console.log("--- AFTER-Trigger Mint ---");
        console.log(label);
        _logSnapshot("  state:", afterState);
        console.log("  mint succeeded:", success ? "YES" : "NO");
        _logComparison("  Mint state comparison:", beforeState, afterState);
    }

    function testMintUntilMaxSupply() public {
        Snapshot memory init = _snapshot();
        _logSnapshot("--- BEFORE-Trigger Initial State ---", init);

        while (token.totalSupply() < MAX_SUPPLY) {
            uint256 currentSupply = token.totalSupply();
            uint256 annualMint = currentSupply * 10 / 100;

            if (currentSupply + annualMint > MAX_SUPPLY) {
                annualMint = MAX_SUPPLY - currentSupply;
            }

            bool success = _mintAndLog("Mint", annualMint);
            assertTrue(success, "Mint failed");

            vm.warp(block.timestamp + 366 days);
        }

        assertEq(token.totalSupply(), MAX_SUPPLY, "Max supply not reached");

        bool successBeyond = _mintAndLog("MintBeyondMax", 1);
        assertFalse(successBeyond, "Mint limit reached");
    }

    function testYearlyMintLimit() public {
        Snapshot memory init = _snapshot();
        _logSnapshot("--- BEFORE-Trigger Yearly Limit Test ---", init);

        uint256 annualMint = token.totalSupply() * 10 / 100;
        bool success1 = _mintAndLog("First Mint", annualMint);
        assertTrue(success1, "First mint failed");

        bool success2 = _mintAndLog("Second Mint (same year)", 1);
        assertFalse(success2, "it exceeds max mintable amount");

        vm.warp(block.timestamp + 366 days);

        annualMint = token.totalSupply() * 10 / 100;
        bool success3 = _mintAndLog("Third Mint (new year)", annualMint);
        assertTrue(success3, "Third mint failed");
    }

    function testZZZDifferentialFinalVerdict() public {
        uint256 annualMint = token.totalSupply() * 10 / 100;
        vm.prank(OWNER);
        token.mint(OWNER, annualMint);

        Snapshot memory beforeState = _snapshot();
        _logSnapshot(
            "--- BEFORE-Trigger Final Differential (second mint same year) ---",
            beforeState
        );

        vm.prank(OWNER);
        (bool success, ) = address(token).call(
            abi.encodeWithSignature("mint(address,uint256)", OWNER, uint256(1))
        );

        Snapshot memory afterState = _snapshot();
        _logSnapshot(
            "--- AFTER-Trigger Final Differential (second mint same year) ---",
            afterState
        );

        bool stateChanged = (afterState.supply != beforeState.supply) ||
            (afterState.ownerBal != beforeState.ownerBal) ||
            (afterState.yearMinted != beforeState.yearMinted);

        console.log("  Second mint succeeded:", success ? "YES" : "NO");
        console.log("  State changed:", stateChanged ? "YES" : "NO");

        if (success && stateChanged) {
            console.log(
                "Vulnerability Exists: A second mint in the same year succeeded and modified totalSupply/OWNER balance/yearMintedAmount"
            );
        } else {
            console.log(
                "Vulnerability not Exist: A second mint in the same year reverted and did not modify totalSupply/OWNER balance/yearMintedAmount"
            );
        }
    }
}