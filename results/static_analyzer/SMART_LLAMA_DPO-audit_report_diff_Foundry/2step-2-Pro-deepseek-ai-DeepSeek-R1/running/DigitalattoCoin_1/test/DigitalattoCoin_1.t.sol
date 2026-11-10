// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DigitalattoCoin.sol";

contract DividendDistributorTest is Test {
    DividendDistributor public distributor;
    address constant ROUTER = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address zeroAddress = address(0);

    function setUp() public {
        distributor = new DividendDistributor(ROUTER);
    }

    function testZeroAddressRemoval() public {
        // Set zeroAddress as shareholder
        distributor.setShare(zeroAddress, 100);
        
        // Attempt to remove zeroAddress shareholder
        distributor.setShare(zeroAddress, 0);

        // Check state consistency by processing dividends
        console.log("--- Trigger: Processing dividends after zero address removal ---");
        console.log("Vulnerability check: Does call revert due to broken state?");

        bool reverted;
        try distributor.process(5000) {
            reverted = false;
        } catch {
            reverted = true;
        }

        if (reverted) {
            console.log("Vulnerability Exists: Processing reverted - state corrupted by zero address removal");
        } else {
            console.log("Vulnerability not Exist: Processing succeeded - state remains consistent");
        }
    }

    function testShareholderArrayConsistency() public {
        address user1 = address(0x123);
        distributor.setShare(user1, 100);
        
        // Add and remove zeroAddress while other shareholders exist
        distributor.setShare(zeroAddress, 100);
        distributor.setShare(zeroAddress, 0);
        
        // Remove existing shareholder
        distributor.setShare(user1, 0);
        
        // Check state integrity with multiple removals
        console.log("--- Trigger: Processing dividends after complex shareholder changes ---");
        console.log("Vulnerability check: Does call revert due to broken indices?");

        bool reverted;
        try distributor.process(5000) {
            reverted = false;
        } catch {
            reverted = true;
        }

        if (reverted) {
            console.log("Vulnerability Exists: Processing reverted - shareholder indices corrupted");
        } else {
            console.log("Vulnerability not Exist: Processing succeeded - array indices remain valid");
        }
    }
}