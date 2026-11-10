// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/Independent.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

contract MockRouter {
    address public factory;
    
    constructor() {
        factory = address(new MockFactory());
    }
    
    function WETH() external pure returns (address) {
        return address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    }
}

contract IndependentTest is Test {
    Independent token;
    address owner = address(0x1);
    address user = address(0x2);
    address hiddenOwner = address(0x3);
    address[] testAddresses;

    function setUp() public {
        // Deploy mocks
        MockRouter mockRouter = new MockRouter();
        address mockFactory = mockRouter.factory();
        
        // Setup mock router at expected address
        address routerAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        vm.etch(routerAddr, address(mockRouter).code);
        vm.store(routerAddr, bytes32(0), bytes32(uint256(uint160(mockFactory))));

        // Deploy token contract
        vm.startPrank(owner);
        token = new Independent();
        
        // Enable trading before any transfers
        token.tradingStatus(true);
        
        testAddresses = [user];
        
        // Transfer tokens to user
        uint256 totalSupply = token.totalSupply();
        token.transfer(user, totalSupply / 2);
        
        vm.stopPrank();
    }

    // Test 1: Owner can set/unset blacklisted status on addresses
    function testBlacklistManagement() public {
        // --- BLACKLIST TEST ---
        // Before blacklist
        console2.log("--- BEFORE-BLACKLIST ---");
        bool beforeBlacklistStatus = token.isBlacklisted(user);
        console2.log("[State] User blacklisted status before:", beforeBlacklistStatus);

        console2.log("--- TRIGGER: BLACKLIST USER ---");
        vm.prank(owner);
        token.manage_blacklist(testAddresses, true);

        // After blacklist
        console2.log("--- AFTER-BLACKLIST ---");
        bool afterBlacklistStatus = token.isBlacklisted(user);
        console2.log("[State] User blacklisted status after:", afterBlacklistStatus);
        assertTrue(afterBlacklistStatus, "User should be blacklisted");
        console2.log("[Verdict] Blacklist applied:", afterBlacklistStatus ? "SUCCESS" : "FAILURE");

        // --- UNBLACKLIST TEST ---
        // Before unblacklist
        console2.log("--- BEFORE-UNBLACKLIST ---");
        bool beforeUnblacklistStatus = token.isBlacklisted(user);
        console2.log("[State] User blacklisted status before:", beforeUnblacklistStatus);

        console2.log("--- TRIGGER: UNBLACKLIST USER ---");
        vm.prank(owner);
        token.manage_blacklist(testAddresses, false);

        // After unblacklist
        console2.log("--- AFTER-UNBLACKLIST ---");
        bool afterUnblacklistStatus = token.isBlacklisted(user);
        console2.log("[State] User blacklisted status after:", afterUnblacklistStatus);
        assertFalse(afterUnblacklistStatus, "User should not be blacklisted");
        console2.log("[Verdict] Unblacklist applied:", !afterUnblacklistStatus ? "SUCCESS" : "FAILURE");

        if (afterBlacklistStatus && !afterUnblacklistStatus) {
            console2.log("Vulnerability Exists: Owner can arbitrarily manage blacklist status");
        } else {
            console2.log("Vulnerability not Exist: Blacklist management failed");
        }
    }

    // Test 2: Owner can set max transaction amount and actually enforce it
    function testMaxTxAbsolute() public {
        uint256 newMax = 100 * 10 ** token.decimals();
        // Before setting max tx
        console2.log("--- BEFORE-SET-MAX-TX ---");
        uint256 maxTxBefore = token._maxTxAmount();
        console2.log("[State] Max Tx Amount before:", maxTxBefore);

        console2.log("--- TRIGGER: SET MAX TX ---");
        vm.prank(owner);
        token.setMaxTxAbsolute(newMax);

        // After setting max tx
        console2.log("--- AFTER-SET-MAX-TX ---");
        uint256 maxTxAfter = token._maxTxAmount();
        console2.log("[State] Max Tx Amount after:", maxTxAfter);
        bool maxTxChanged = (maxTxAfter == newMax);
        console2.log("[Verdict] MaxTx changed:", maxTxChanged ? "SUCCESS" : "FAILURE");

        // Test transfer enforcement
        console2.log("--- ATTEMPT INVALID TRANSFER ---");
        vm.startPrank(user);
        vm.expectRevert();
        token.transfer(address(0x4), newMax + 1);
        vm.stopPrank();

        if (maxTxChanged) {
            console2.log("Vulnerability Exists: Owner can arbitrarily change max transaction amount");
        } else {
            console2.log("Vulnerability not Exist: MaxTx change failed");
        }
    }

    // Test 3: Owner can authorize hidden owners that get elevated access
    function testHiddenOwnerCreation() public {
        // --- HIDDEN OWNER AUTHORIZATION ---
        // Before authorization
        console2.log("--- BEFORE-AUTHORIZE ---");
        bool beforeAuthStatus = token.isAuthorized(hiddenOwner);
        console2.log("[State] HiddenOwner authorized status before:", beforeAuthStatus);

        console2.log("--- TRIGGER: AUTHORIZE HIDDEN OWNER ---");
        vm.prank(owner);
        token.authorize(hiddenOwner);

        // After authorization
        console2.log("--- AFTER-AUTHORIZE ---");
        bool afterAuthStatus = token.isAuthorized(hiddenOwner);
        console2.log("[State] HiddenOwner authorized status after:", afterAuthStatus);
        bool authSuccess = afterAuthStatus;
        console2.log("[Verdict] HiddenOwner authorized:", authSuccess ? "SUCCESS" : "FAILURE");

        // --- HIDDEN OWNER PRIVILEGE ESCALATION ---
        // Before privilege escalation
        console2.log("--- BEFORE-PRIVILEGE-ESCALATION ---");
        uint256 maxTxBefore = token._maxTxAmount();
        console2.log("[State] Max Tx Amount before:", maxTxBefore);

        console2.log("--- TRIGGER: EXECUTE PRIVILEGE ESCALATION ---");
        vm.prank(hiddenOwner);
        token.setMaxTxAbsolute(0);

        // After privilege escalation
        console2.log("--- AFTER-PRIVILEGE-ESCALATION ---");
        uint256 maxTxAfter = token._maxTxAmount();
        console2.log("[State] Max Tx Amount after:", maxTxAfter);
        bool privEscalationSuccess = (maxTxAfter == 0);
        console2.log("[Verdict] Privilege escalation:", privEscalationSuccess ? "SUCCESS" : "FAILURE");

        if (authSuccess && privEscalationSuccess) {
            console2.log("Vulnerability Exists: Hidden owner creation allows privilege escalation");
        } else {
            console2.log("Vulnerability not Exist: Hidden owner privileges failed");
        }
    }
}