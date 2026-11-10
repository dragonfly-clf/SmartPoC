// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/XRPNATION.sol";

contract MockFactory {
    address private immutable PAIR_ADDRESS;

    constructor(address _pairAddr) {
        PAIR_ADDRESS = _pairAddr;
    }
    
    function createPair(address, address) external view returns (address) {
        return PAIR_ADDRESS;
    }
}

contract MockRouter {
    address public immutable factory;
    
    constructor(address _factory) {
        factory = _factory;
    }

    // Add dummy functions to satisfy interface requirements
    function addLiquidityETH(
        address, uint, uint, uint, address, uint
    ) external payable returns (uint, uint, uint) {
        return (0,0,0);
    }
}

contract StopTransactionsTest is Test {
    XRPNATION token;
    
    address owner = address(0x1);
    address alice = address(0x2);
    address bob = address(0x3);
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant MOCK_PAIR_ADDRESS = address(0x1234);

    function setUp() public {
        // Deploy actual mock factory
        MockFactory mockFactory = new MockFactory(MOCK_PAIR_ADDRESS);
        MockRouter mockRouter = new MockRouter(address(mockFactory));
        
        // Properly mock existing router contract
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        
        // Deploy token contract
        vm.startPrank(owner);
        token = new XRPNATION();
        token.tradingStatus(true);
        token.transfer(alice, 1e18);
        vm.stopPrank();
    }

    // Helper function to get current token state
    function getTokenState() internal view returns (bool, uint256, uint256) {
        return (
            token.tradingOpen(),
            token._maxWalletToken(),
            token._maxSellTxAmount()
        );
    }

    function test_stopTransactionsViaTradingStatus() public {
        (bool tradingOpenBefore, uint256 maxWalletBefore, uint256 maxSellBefore) = getTokenState();
        console.log("--- BEFORE-Trigger Trading Status ---");
        console.log("tradingOpen: %s", tradingOpenBefore);
        console.log("_maxWalletToken: %d", maxWalletBefore);
        console.log("_maxSellTxAmount: %d", maxSellBefore);
        
        console.log("--- Trigger: Change Trading Status ---");
        vm.prank(owner);
        token.tradingStatus(false);

        (bool tradingOpenAfter, uint256 maxWalletAfter, uint256 maxSellAfter) = getTokenState();
        console.log("--- AFTER-Trigger Trading Status ---");
        console.log("tradingOpen: %s", tradingOpenAfter);
        console.log("_maxWalletToken: %d", maxWalletAfter);
        console.log("_maxSellTxAmount: %d", maxSellAfter);
        
        // Verdict: If tradingOpen changed, vulnerability exists
        if (tradingOpenAfter == false) {
            console.log("Vulnerability Exists: Trading successfully disabled");
        } else {
            console.log("Vulnerability not Exist: TradingOpen unexpectedly true");
        }

        // Original transfer check remains
        vm.prank(alice);
        vm.expectRevert("Trading not open yet");
        token.transfer(bob, 1e17);
    }

    function test_stopTransactionsViaMaxWalletZero() public {
        (bool tradingOpenBefore, uint256 maxWalletBefore, uint256 maxSellBefore) = getTokenState();
        console.log("--- BEFORE-Trigger Max Wallet ---");
        console.log("tradingOpen: %s", tradingOpenBefore);
        console.log("_maxWalletToken: %d", maxWalletBefore);
        console.log("_maxSellTxAmount: %d", maxSellBefore);
        
        console.log("--- Trigger: Set Max Wallet to 0%% ---");
        vm.prank(owner);
        token.setMaxWalletPercent_base1000(0);

        (bool tradingOpenAfter, uint256 maxWalletAfter, uint256 maxSellAfter) = getTokenState();
        console.log("--- AFTER-Trigger Max Wallet ---");
        console.log("tradingOpen: %s", tradingOpenAfter);
        console.log("_maxWalletToken: %d", maxWalletAfter);
        console.log("_maxSellTxAmount: %d", maxSellAfter);
        
        // Verdict: If wallet limit set to 0, vulnerability exists
        if (maxWalletAfter == 0) {
            console.log("Vulnerability Exists: Max wallet limit set to zero");
        } else {
            console.log("Vulnerability not Exist: MaxWalletToken not zero");
        }

        // Original transfer check remains
        vm.prank(alice);
        vm.expectRevert("Total Holding is currently limited, you can not buy that much.");
        token.transfer(bob, 1);
    }

    function test_stopTransactionsViaMaxSellZero() public {
        (bool tradingOpenBefore, uint256 maxWalletBefore, uint256 maxSellBefore) = getTokenState();
        console.log("--- BEFORE-Trigger Max Sell ---");
        console.log("tradingOpen: %s", tradingOpenBefore);
        console.log("_maxWalletToken: %d", maxWalletBefore);
        console.log("_maxSellTxAmount: %d", maxSellBefore);
        
        console.log("--- Trigger: Set Max Sell to 0%% ---");
        vm.prank(owner);
        token.setMaxSellTxPercent_base1000(0);

        (bool tradingOpenAfter, uint256 maxWalletAfter, uint256 maxSellAfter) = getTokenState();
        console.log("--- AFTER-Trigger Max Sell ---");
        console.log("tradingOpen: %s", tradingOpenAfter);
        console.log("_maxWalletToken: %d", maxWalletAfter);
        console.log("_maxSellTxAmount: %d", maxSellAfter);
        
        // Verdict: If max sell set to zero, vulnerability exists
        if (maxSellAfter == 0) {
            console.log("Vulnerability Exists: Max sell amount set to zero");
        } else {
            console.log("Vulnerability not Exist: MaxSellTxAmount not zero");
        }

        // Original transfer check remains
        vm.prank(alice);
        vm.expectRevert("TX Limit Exceeded");
        token.transfer(MOCK_PAIR_ADDRESS, 1);
    }
}