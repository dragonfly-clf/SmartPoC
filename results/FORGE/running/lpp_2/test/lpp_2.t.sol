// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "../src/LinerPowerPoint.sol";

contract BlacklistTest is Test {
    LinerPowerPoint token;
    address constant PANCAKE_ROUTER = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address owner = address(0x1);
    address user1 = address(0x2);
    address user2 = address(0x3);
    address mockFactory = address(0x888);
    address mockWETH = address(0x999);
    address mockPair = address(0x777);

    // How many storage "base slots" to probe when looking for the blacklist mapping.
    uint256 constant SCAN_SLOTS = 150;

    function setUp() public {
        // Mock PancakeSwap Router calls
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );

        // Mock Factory createPair call
        bytes4 createPairSelector = bytes4(keccak256("createPair(address,address)"));
        vm.mockCall(
            mockFactory,
            createPairSelector,
            abi.encode(mockPair)
        );

        // Deploy token - now constructor calls will use our mocks
        vm.prank(owner);
        token = new LinerPowerPoint();
    }

    // ---------------------------------------------------------------
    // Original tests (preserved verbatim / not overridden)
    // ---------------------------------------------------------------
    function testOwnerCanBlacklistArbitraryAddresses() public {
        // Create bot addresses array
        address[] memory bots = new address[](2);
        bots[0] = user1;
        bots[1] = user2;

        // Owner blacklists addresses
        vm.prank(owner);
        token.addBots(bots, true);

        // Verify addresses are blacklisted (assuming botlist is public)
        // If not, main point is that function doesn't revert
    }

    function testOwnerCanChangeBlacklistStatus() public {
        // Create bot addresses array
        address[] memory bots = new address[](1);
        bots[0] = user1;

        // Blacklist
        vm.prank(owner);
        token.addBots(bots, true);

        // Unblacklist the same address
        vm.prank(owner);
        token.addBots(bots, false);
    }

    // ---------------------------------------------------------------
    // Differential validation
    //
    // Because the exact public getter name of the botlist mapping is
    // NOT known (calling `token.botlist(...)` failed to compile), we
    // query the mapping state through raw storage using `vm.load`.
    //
    // For a `mapping(address => bool)` located at base slot `S`, the
    // entry for `account` lives at:
    //     keccak256(abi.encode(account, S))
    // We scan S in [0, SCAN_SLOTS) before and after `addBots`, and the
    // slot where BOTH user1 and user2 flip 0 -> nonzero is the blacklist
    // mapping base slot.
    // ---------------------------------------------------------------
    function testDifferentialOwnerCanModifyBotlistState() public {
        address[] memory bots = new address[](2);
        bots[0] = user1;
        bots[1] = user2;

        // ===================== (i) BEFORE-Trigger =====================
        console.log("==========================================================");
        console.log("(i) BEFORE-Trigger Action & State Snapshot");
        console.log("==========================================================");

        uint256[] memory preU1 = _scanStorage(user1, SCAN_SLOTS);
        uint256[] memory preU2 = _scanStorage(user2, SCAN_SLOTS);

        console.log("    Queried mapping storage keys keccak256(account, slot) for slots 0..149.");
        _logBool("    user1 has NO blacklist entries before (all scanned slots zero): ", _allZero(preU1));
        _logBool("    user2 has NO blacklist entries before (all scanned slots zero): ", _allZero(preU2));

        // ===================== (ii) TRIGGER ===========================
        console.log("==========================================================");
        console.log("(ii) Trigger Operation: owner.addBots([user1,user2], true)");
        console.log("==========================================================");
        vm.prank(owner);
        token.addBots(bots, true);

        // ===================== (iii) AFTER-Trigger ====================
        console.log("==========================================================");
        console.log("(iii) AFTER-Trigger Action & State Snapshot");
        console.log("==========================================================");

        uint256[] memory postU1 = _scanStorage(user1, SCAN_SLOTS);
        uint256[] memory postU2 = _scanStorage(user2, SCAN_SLOTS);

        (bool found, uint256 slot) = _findCommonChangedSlot(preU1, postU1, preU2, postU2);

        if (found) {
            console.log(string.concat("    Located blacklist mapping base slot index: ", vm.toString(slot)));
            console.log(string.concat("    user1 mapping entry: ", vm.toString(preU1[slot]), " -> ", vm.toString(postU1[slot])));
            console.log(string.concat("    user2 mapping entry: ", vm.toString(preU2[slot]), " -> ", vm.toString(postU2[slot])));
        } else {
            console.log("    No mapping slot changed 0 -> nonzero for BOTH users.");
        }

        // ===================== (iv) VERDICT - PHASE A =================
        console.log("(iv) Comparison verdict - blacklist phase (expect 0 -> 1 for both users):");
        _logBool("    user1 state changed false->true: ", found);
        _logBool("    user2 state changed false->true: ", found);

        // ===================== (i) BEFORE - UNBLACKLIST PHASE =========
        address[] memory oneBot = new address[](1);
        oneBot[0] = user1;

        console.log("==========================================================");
        console.log("(i) BEFORE-Trigger Action & State Snapshot (unblacklist phase)");
        console.log("==========================================================");
        uint256 beforeClear = found ? _readSlotFor(user1, slot) : 0;
        console.log(string.concat("    user1 blacklist entry before clear: ", vm.toString(beforeClear)));

        // ===================== (ii) TRIGGER - UNBLACKLIST =============
        console.log("==========================================================");
        console.log("(ii) Trigger Operation: owner.addBots([user1], false)");
        console.log("==========================================================");
        vm.prank(owner);
        token.addBots(oneBot, false);

        // ===================== (iii) AFTER - UNBLACKLIST ==============
        console.log("==========================================================");
        console.log("(iii) AFTER-Trigger Action & State Snapshot (unblacklist phase)");
        console.log("==========================================================");
        uint256 afterClear = found ? _readSlotFor(user1, slot) : 0;
        console.log(string.concat("    user1 blacklist entry after clear: ", vm.toString(afterClear)));

        // ===================== (iv) VERDICT - PHASE B =================
        console.log("(iv) Comparison verdict - unblacklist phase (expect nonzero -> 0):");
        bool removed1 = found && beforeClear != 0 && afterClear == 0;
        _logBool("    user1 state changed true->false: ", removed1);

        bool exploitSucceeded = found && removed1;
        _logBool("    FINAL: owner can arbitrarily mutate blacklist state: ", exploitSucceeded);

        if (exploitSucceeded) {
            console.log("Vulnerability Exists: owner.addBots() freely sets and clears arbitrary addresses' blacklist mapping entries (0->1->0) with no restriction");
        } else {
            console.log("Vulnerability not Exist: blacklist mapping entry did not change 0->1->0 as expected");
        }
    }

    // ---------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------

    // Reads, for every candidate base slot s, the value stored at the
    // mapping-derived key keccak256(abi.encode(account, s)).
    function _scanStorage(address account, uint256 maxSlots) internal returns (uint256[] memory vals) {
        vals = new uint256[](maxSlots);
        for (uint256 s = 0; s < maxSlots; s++) {
            bytes32 key = keccak256(abi.encode(account, s));
            vals[s] = uint256(vm.load(address(token), key));
        }
    }

    // Reads the mapping-derived slot for `account` given a base slot index.
    function _readSlotFor(address account, uint256 slot) internal returns (uint256) {
        bytes32 key = keccak256(abi.encode(account, slot));
        return uint256(vm.load(address(token), key));
    }

    // Finds a base slot where BOTH accounts flipped 0 -> nonzero.
    function _findCommonChangedSlot(
        uint256[] memory b1,
        uint256[] memory a1,
        uint256[] memory b2,
        uint256[] memory a2
    ) internal pure returns (bool found, uint256 slot) {
        for (uint256 s = 0; s < b1.length; s++) {
            if (b1[s] == 0 && a1[s] != 0 && b2[s] == 0 && a2[s] != 0) {
                return (true, s);
            }
        }
        return (false, 0);
    }

    function _allZero(uint256[] memory arr) internal pure returns (bool) {
        for (uint256 i = 0; i < arr.length; i++) {
            if (arr[i] != 0) return false;
        }
        return true;
    }

    function _logBool(string memory label, bool value) internal {
        if (value) {
            console.log(string.concat(label, "true"));
        } else {
            console.log(string.concat(label, "false"));
        }
    }
}