// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Fund.sol";

contract MockERC20 {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        require(
            allowance[from][msg.sender] >= amount,
            "ERC20: insufficient allowance"
        );
        return true;
    }
}

contract MockTwapOracle {
    function getTwap(uint256) external view returns (uint256) {
        return 1e18;
    }
}

contract MockAprOracle {
    function capture() external returns (uint256) {
        return 0;
    }
}

contract MockBallot {}

contract MockPrimaryMarket is IPrimaryMarket {
    uint256 public creationUnderlying;
    uint256 public redemptionUnderlying;
    
    function setCreationAmounts(
        uint256 creation,
        uint256 redemption
    ) external {
        creationUnderlying = creation;
        redemptionUnderlying = redemption;
    }
    
    function settle(
        uint256, 
        uint256, 
        uint256, 
        uint256, 
        uint256
    ) external override returns (
        uint256, uint256, uint256, uint256, uint256
    ) {
        return (
            0,
            0,
            creationUnderlying,
            redemptionUnderlying,
            0
        );
    }

    function claim(address) external override returns (uint256, uint256) {
        return (0, 0);
    }
}

contract FundArbitrarySendERC20Test is Test {
    Fund fund;
    MockERC20 underlying;
    MockPrimaryMarket pm;
    address feeCollector = address(0xfee);

    function setUp() public {
        // Set timestamp to avoid overflow
        vm.warp(172800); // 2 days

        underlying = new MockERC20();
        MockTwapOracle twapOracle = new MockTwapOracle();
        MockAprOracle aprOracle = new MockAprOracle();
        MockBallot ballot = new MockBallot();
        
        fund = new Fund(
            address(underlying),
            18,
            0,
            2e18,
            1e18,
            address(twapOracle),
            address(aprOracle),
            address(ballot),
            feeCollector
        );
        
        pm = new MockPrimaryMarket();
        fund.addNewPrimaryMarket(address(pm));
    }

    function testSettlementFailsWithoutAllowance() public {
        // Log pre-conditions
        console.log("--- BEFORE-Trigger Setup ---");
        console.log("Setup complete: Timestamp initialized, market active");

        // Step 1: Activate primary market by settling current day
        vm.warp(fund.currentDay());
        fund.settle();

        // Step 2: Prepare market data for next settlement
        pm.setCreationAmounts(100, 0);
        underlying.mint(address(pm), 100);
        
        // Step 3: Move to next settlement day
        vm.warp(fund.currentDay() + 1 days);
        
        // Log trigger information
        console.log("--- Trigger Settlement ---");
        console.log("Simulating settlement call WITHOUT token allowance");

        // Step 4: Test transaction with expected revert
        (bool success,) = address(fund).call(abi.encodeWithSignature("settle()"));
        
        // Post-trigger analysis and verdict
        console.log("--- AFTER-Trigger Result ---");
        if (success) {
            console.log("Vulnerability Exists: Settlement succeeded without required token allowance");
        } else {
            console.log("Vulnerability not Exist: Settlement reverted as expected without allowance");
        }
    }
}