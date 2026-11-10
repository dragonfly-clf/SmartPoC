// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Nabana.sol";

contract MockNabana {
    function mintWithPermit(address, uint256) external pure returns (bool) {
        return true;
    }
}

contract NabanaAuditTest is Test {
    NabanaDividendTracker public dividendTracker;
    MockNabana public mockNabana;
    address privateAccount = address(0x1000);

    function setUp() public {
        mockNabana = new MockNabana();
        dividendTracker = new NabanaDividendTracker(address(mockNabana));
    }

    function testExcludedAccountReaddedToInvestorsMap() public {
        // Account setup
        dividendTracker.excludeFromDividends(privateAccount);
        assertTrue(dividendTracker.excludedFromDividends(privateAccount));
        dividendTracker.setBalance(privateAccount, 0);

        console.log("--- BEFORE-Trigger setBalance ---");
        (,,,,, uint256 investmentBefore,) = dividendTracker.getAccount(privateAccount);
        console.log("Investment balance before:", investmentBefore);
        assertEq(investmentBefore, 0, "Account should start with zero balance");

        console.log("--- Trigger setBalance ---");
        // Critical vulnerability trigger
        uint8 result = dividendTracker.setBalance(privateAccount, 1);

        console.log("--- AFTER-Trigger setBalance ---");
        (,,,,, uint256 investmentAfter,) = dividendTracker.getAccount(privateAccount);
        console.log("Investment balance after:", investmentAfter);

        // Vulnerability verification logic
        if(investmentAfter > 0) {
            console.log("Vulnerability Exists: Excluded account improperly added to investors map");
        } else {
            console.log("Vulnerability not Exist: Exclusion state maintained properly");
        }

        // Additional assertions
        assertEq(result, 2, "Result should be 'excluded account' (2)");
        assertGt(investmentAfter, 0, "Vulnerability: Excluded account added to investors map");
        assertEq(investmentAfter, 1, "Account balance should be set to 1 wei");
    }
}