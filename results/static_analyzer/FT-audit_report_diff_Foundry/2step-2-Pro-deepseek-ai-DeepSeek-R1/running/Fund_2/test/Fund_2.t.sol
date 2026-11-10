// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Fund.sol";

contract SafeTwapOracle {
    function getTwap(uint256) external view returns (uint256) {
        return 1e18; // Return valid price
    }
}

contract SafeAprOracle {
    function capture() external returns (uint256) {
        return 1e18;
    }
}

contract FundTest is Test {
    Fund public fund;
    address constant NON_CONTRACT = address(0x999);

    function setUp() public {
        // Set safe starting timestamp (at least 1 day after epoch)
        vm.warp(48 hours);
        
        SafeTwapOracle safeTwap = new SafeTwapOracle();
        SafeAprOracle safeApr = new SafeAprOracle();
        
        // Deploy fund with proper safe values
        fund = new Fund(
            address(this), 
            18, 
            5e16, 
            10500, 
            9500, 
            address(safeTwap),
            address(safeApr),
            address(this),
            address(this)
        );
    }

    function testNonContractCallReverts() public {
        console.log("--- BEFORE-Trigger ---");
        console.log("Initial TWAP Oracle: %s", address(fund.twapOracle()));
        console.log("Current block timestamp: %s", block.timestamp);

        console.log("--- Trigger: UpdateTwapOracle ---");
        fund.updateTwapOracle(NON_CONTRACT);

        console.log("--- AFTER-Trigger: Oracle Updated ---");
        console.log("Updated TWAP Oracle: %s", address(fund.twapOracle()));
        
        console.log("--- Trigger: Warp ---");
        uint256 nextDay = fund.endOfDay(block.timestamp) + 1 days;
        vm.warp(nextDay + 1);
        console.log("Warped to nextDay+1: %s", nextDay+1);

        console.log("--- AFTER-Trigger: Warp Complete ---");
        console.log("New block timestamp: %s", block.timestamp);

        console.log("--- Trigger: Settle ---");
        (bool success, ) = address(fund).call(
            abi.encodeWithSignature("settle()")
        );
        
        if (success) {
            console.log("Settlement call succeeded unexpectedly");
        } else {
            console.log("Settlement call reverted as expected");
        }
        
        // Final verdict based on settlement revert status
        require(!success, "Settlement should have reverted");
        console.log("Vulnerability Exists: Setting non-contract address as TWAP oracle causes settlement to revert");
    }
}