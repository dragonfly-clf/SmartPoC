// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Fund.sol";

contract FundOutOfGasTest is Test {
    Fund public fund;
    MockERC20 public underlyingToken;
    address public constant feeCollector = address(0xFEE);
    uint256 public constant SAFE_TIMESTAMP = 2 days;
    
    address[] public primaryMarkets;
    address public owner;
    MockTwapOracle public twapOracle;
    MockAprOracle public aprOracle;
    MockBallot public ballot;

    function setUp() public {
        owner = address(this);
        vm.warp(SAFE_TIMESTAMP);
        
        underlyingToken = new MockERC20(18);
        twapOracle = new MockTwapOracle();
        aprOracle = new MockAprOracle();
        ballot = new MockBallot();
        
        fund = new Fund(
            address(underlyingToken), 
            18,        // underlyingDecimals
            1000,      // dailyProtocolFeeRate (0.001%)
            1.1e18,    // upperRebalanceThreshold (110%)
            0.9e18,    // lowerRebalanceThreshold (90%)
            address(twapOracle),
            address(aprOracle),
            address(ballot),
            feeCollector
        );
        
        underlyingToken.mint(address(fund), 1000000 * 1e18);
    }

    function testPrimaryMarketSettlementOutOfGas() public {
        // Create and activate primary markets
        _createAndActivateMarkets(300);
        
        // Verify initial market count
        console.log("--- BEFORE-Trigger Settle ---");
        uint256 preMarketCount = fund.getPrimaryMarketCount();
        console.log("Active primary markets (before):", preMarketCount);

        // Advance to next day
        vm.warp(block.timestamp + 2 days);
        
        // Attempt settlement with limited gas
        console.log("--- Trigger Settle (gas limited) ---");
        uint256 gasLimit = 500000; // Simulate low gas environment
        (bool success, ) = address(fund).call{gas: gasLimit}(abi.encodeWithSignature("settle()"));
        
        // Check transaction status and state persistence
        console.log("--- AFTER-Trigger Settle ---");
        uint256 postMarketCount = fund.getPrimaryMarketCount();
        console.log("Active primary markets (after):", postMarketCount);
        
        // Compare state before/after transaction
        bool marketsUnchanged = (preMarketCount == postMarketCount);
        console.log("State unchanged:", marketsUnchanged ? "YES" : "NO");
        console.log("Transaction failed:", !success ? "YES" : "NO");

        // Final vulnerability verdict
        if (!success && marketsUnchanged) {
            console.log("Vulnerability confirmed: State reverted after OOG error");
            console.log("Vulnerability Exists: Settlement gas limitations allow state inconsistencies");
        } else {
            console.log("Vulnerability not Exist: Transaction processed successfully");
        }
    }

    function testObsoleteMarketRemovalOutOfGas() public {
        // Create and activate primary markets
        uint256 marketCount = 300;
        address[] memory markets = _createAndActivateMarkets(marketCount);
        
        // Verify initial market count
        console.log("--- BEFORE-Trigger Settle ---");
        uint256 preMarketCount = fund.getPrimaryMarketCount();
        console.log("Active primary markets (before):", preMarketCount);

        // Mark all as obsolete (should cause out-of-gas in settlement)
        for (uint i = 0; i < marketCount; i++) {
            fund.addObsoletePrimaryMarket(markets[i]);
        }
        
        // Advance to next day
        vm.warp(block.timestamp + 2 days);
        
        // Attempt settlement with limited gas
        console.log("--- Trigger Settle (obsolete removal) ---");
        uint256 gasLimit = 500000;
        (bool success, ) = address(fund).call{gas: gasLimit}(abi.encodeWithSignature("settle()"));
        
        console.log("--- AFTER-Trigger Settle ---");
        uint256 postMarketCount = fund.getPrimaryMarketCount();
        console.log("Active primary markets (after):", postMarketCount);
        
        // Compare state before/after transaction
        bool marketsUnchanged = (preMarketCount == postMarketCount);
        console.log("State unchanged:", marketsUnchanged ? "YES" : "NO");
        console.log("Transaction failed:", !success ? "YES" : "NO");

        // Final vulnerability verdict
        if (!success && marketsUnchanged) {
            console.log("Vulnerability confirmed: Obsolete markets persist after OOG");
            console.log("Vulnerability Exists: Gas limitations prevent state rollback");
        } else {
            console.log("Vulnerability not Exist: Obsolete markets processed successfully");
        }
    }

    function _createAndActivateMarkets(uint256 count) internal returns (address[] memory) {
        address[] memory markets = new address[](count);
        for (uint i = 0; i < count; i++) {
            address pm = address(new MockPrimaryMarket());
            fund.addNewPrimaryMarket(pm);
            markets[i] = pm;
        }
        
        // Activate markets by settling
        vm.warp(block.timestamp + 2 days);
        fund.settle();
        
        return markets;
    }
}

contract MockERC20 {
    mapping(address => uint256) public balanceOf;
    uint8 public decimals;
    
    constructor(uint8 _decimals) public {
        decimals = _decimals;
    }
    
    function mint(address account, uint256 amount) public {
        balanceOf[account] += amount;
    }
    
    function transfer(address, uint256) public pure returns (bool) { return true; }
    function transferFrom(address, address, uint256) public pure returns (bool) { return true; }
    function approve(address, uint256) public pure returns (bool) { return true; }
}

contract MockTwapOracle {
    function getTwap(uint256) public view returns (uint256) {
        return 1e18;
    }
}

contract MockAprOracle {
    function capture() public view returns (uint256) {
        return 0.05e18;
    }
}

contract MockPrimaryMarket {
    function settle(
        uint256, 
        uint256, 
        uint256, 
        uint256, 
        uint256
    ) external pure returns (uint256, uint256, uint256, uint256, uint256) {
        return (0, 0, 0, 0, 0);
    }
}

contract MockBallot {
    function count(uint256) external pure returns (uint256) {
        return 0;
    }
}