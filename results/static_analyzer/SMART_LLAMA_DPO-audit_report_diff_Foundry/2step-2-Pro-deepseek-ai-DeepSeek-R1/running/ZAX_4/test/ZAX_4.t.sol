// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ZAX.sol";

contract MockWETH {
    // Mock WETH contract
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1);
    }
}

contract MockRouter {
    address public immutable _factory;
    address public immutable weth;

    constructor(address factory_, address weth_) {
        _factory = factory_;
        weth = weth_;
    }

    function factory() external view returns (address) {
        return _factory;
    }

    function WETH() external view returns (address) {
        return weth;
    }
}

contract ZAXPrivilegeTest is Test {
    ZAX token;
    address owner = address(0x1);
    address attacker = address(0x2);
    MockFactory factory;
    MockRouter router;
    MockWETH weth;

    function setUp() public {
        weth = new MockWETH();
        factory = new MockFactory();
        router = new MockRouter(address(factory), address(weth));
        
        vm.prank(owner);
        token = new ZAX(address(router));
    }

    function testAttackerCannotDisableTrading() public {
        console.log("--- BEFORE-Trigger SetTradingStatus (attacker) ---");
        bool tradingEnabledBefore = token.tradingEnabled();
        bool swapEnabledBefore = token.swapEnabled();
        console.log("tradingEnabled before: %s", tradingEnabledBefore);
        console.log("swapEnabled before: %s", swapEnabledBefore);

        console.log("--- Trigger SetTradingStatus (attacker) ---");
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setTradingStatus(false, 0, 0, 0, 0, 0); // 6 params: state,deadline,rfi,marketing,liquidity,buyback

        console.log("--- AFTER-Trigger SetTradingStatus (attacker) ---");
        bool tradingEnabledAfter = token.tradingEnabled();
        bool swapEnabledAfter = token.swapEnabled();
        console.log("tradingEnabled after: %s", tradingEnabledAfter);
        console.log("swapEnabled after: %s", swapEnabledAfter);

        // Validate state changes
        if (tradingEnabledBefore != tradingEnabledAfter || swapEnabledBefore != swapEnabledAfter) {
            console.log("Vulnerability Exists: Unauthorized state change by attacker");
        } else {
            console.log("Vulnerability not Exist: State unchanged after attacker action");
        }
    }

    function testOwnerCanUpdateTradingStatus() public {
        console.log("--- BEFORE-Trigger SetTradingStatus (owner) ---");
        bool tradingEnabledBefore = token.tradingEnabled();
        bool swapEnabledBefore = token.swapEnabled();
        console.log("tradingEnabled before: %s", tradingEnabledBefore);
        console.log("swapEnabled before: %s", swapEnabledBefore);

        console.log("--- Trigger SetTradingStatus (owner) ---");
        vm.prank(owner);
        token.setTradingStatus(false, 0, 0, 0, 0, 0);

        console.log("--- AFTER-Trigger SetTradingStatus (owner) ---");
        bool tradingEnabledAfter = token.tradingEnabled();
        bool swapEnabledAfter = token.swapEnabled();
        console.log("tradingEnabled after: %s", tradingEnabledAfter);
        console.log("swapEnabled after: %s", swapEnabledAfter);

        // Validate tradingEnabled was disabled
        if (!tradingEnabledAfter) {
            console.log("Vulnerability not Exist: Owner correctly updated trading status");
        } else {
            console.log("Vulnerability Exists: Trading status unchanged by owner");
        }
    }
}