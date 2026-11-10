// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GREENWORLD.sol";

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0x1234);
    }
}

contract MockRouter {
    address public immutable factory;

    constructor(address _factory) {
        factory = _factory;
    }

    function WETH() external pure returns (address) {
        return address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
}

contract GREENWORLDTest is Test {
    GREENWORLD token;
    MockFactory factory;
    MockRouter router;
    address owner = address(this);
    address nonOwner = address(0xBAD);

    function setUp() public {
        factory = new MockFactory();
        router = new MockRouter(address(factory));
        token = new GREENWORLD(address(router));
    }

    function test_OwnerCanSetTradingStatusWithoutRevert() public {
        token.setTradingStatus(
            true,       // state
            999999,     // _deadline
            1,          // rfi
            2,          // charity
            3,          // liquidity
            4,          // utility
            5,          // operation
            6           // burn
        );
        // If we get this far, owner call didn't revert - test passes
    }

    function test_NonOwnerCannotSetTradingStatus() public {
        console.log("--- BEFORE-Trigger setTradingStatus ---");
        bool tradingEnabledBefore = token.tradingEnabled();
        bool swapEnabledBefore = token.swapEnabled();
        console.log("tradingEnabled state (before):", tradingEnabledBefore);
        console.log("swapEnabled state (before):", swapEnabledBefore);
        
        console.log("--- Trigger setTradingStatus by nonOwner ---");
        vm.prank(nonOwner);
        try token.setTradingStatus(
            true,       // state
            999999,     // _deadline
            1,          // rfi
            2,          // charity
            3,          // liquidity
            4,          // utility
            5,          // operation
            6           // burn
        ) {
            console.log("Call did NOT revert!");
        } catch Error(string memory reason) {
            console.log("Call reverted with reason:", reason);
        }
        
        console.log("--- AFTER-Trigger setTradingStatus ---");
        bool tradingEnabledAfter = token.tradingEnabled();
        bool swapEnabledAfter = token.swapEnabled();
        console.log("tradingEnabled state (after):", tradingEnabledAfter);
        console.log("swapEnabled state (after):", swapEnabledAfter);
        
        // Differential comparison
        bool vulnerable = tradingEnabledBefore != tradingEnabledAfter || 
                          swapEnabledBefore != swapEnabledAfter;
        
        console.log("--- Differential Verdict ---");
        console.log("State changed:", vulnerable ? "YES" : "NO");
        
        // Final verdict with exact required format
        if (vulnerable) {
            console.log("Vulnerability Exists: Non-owner successfully modified trading/swap state");
        } else {
            console.log("Vulnerability not Exist: State remains unchanged after non-owner call");
        }
    }
}