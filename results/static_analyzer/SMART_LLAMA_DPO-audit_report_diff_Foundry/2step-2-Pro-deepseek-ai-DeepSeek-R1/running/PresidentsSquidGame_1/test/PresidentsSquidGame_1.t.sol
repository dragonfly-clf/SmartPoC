// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PresidentsSquidGame.sol";

// Mock contracts for Uniswap router and factory
contract MockRouter {
    address public immutable _factory;
    address public immutable _WETH;

    constructor(address factoryAddr, address wethAddr) {
        _factory = factoryAddr;
        _WETH = wethAddr;
    }

    function factory() external view returns (address) {
        return _factory;
    }

    function WETH() external view returns (address) {
        return _WETH;
    }
}

contract MockFactory {
    address public immutable _pairAddress;

    constructor(address pairAddr) {
        _pairAddress = pairAddr;
    }

    function createPair(address, address) external view returns (address) {
        return _pairAddress;
    }
}

contract PresidentsSquidGameTest is Test {
    PresidentsSquidGame token;
    address owner = address(0x1);
    address user1 = address(0x2);
    address rewardAddress = address(0x8);
    address constant realPancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address mockWETH = address(0x5);
    address ammPair = address(0x4);
    uint256 initialAmount = 1000 * 10**18;
    
    function setUp() public {
        // Deploy mocks with distinct state variable names
        MockFactory mockFactory = new MockFactory(ammPair);
        MockRouter mockRouter = new MockRouter(address(mockFactory), mockWETH);
        
        // Patch real PancakeSwap router with mock code
        vm.etch(realPancakeRouter, address(mockRouter).code);
        
        vm.startPrank(owner);
        token = new PresidentsSquidGame();
        token.setRewardAddress(rewardAddress);
        token.excludeFromFees(rewardAddress, true);  // Ensure reward address is excluded
        token.setSellFee(5);  // 5% sell fee
        token.setIsTradingEnabled(true);
        token.transfer(user1, initialAmount);
        vm.stopPrank();
    }
    
    function testAccountingVulnerability() public {
        // Pre-transfer balances
        console.log("--- BEFORE-Trigger State ---");
        uint256 ownerBalBefore = token.balanceOf(owner);
        uint256 user1BalBefore = token.balanceOf(user1);
        uint256 ammPairBalBefore = token.balanceOf(ammPair);
        uint256 rewardBalBefore = token.balanceOf(rewardAddress);
        uint256 totalSupplyBefore = token.totalSupply();
        
        console.log("Owner balance before:", ownerBalBefore);
        console.log("User1 balance before:", user1BalBefore);
        console.log("AMM pair balance before:", ammPairBalBefore);
        console.log("Reward address balance before:", rewardBalBefore);
        console.log("Total supply before:", totalSupplyBefore);
        
        // Compute sent amount and expected fee
        uint256 transferAmount = token.balanceOf(user1);
        uint256 expectedFee = transferAmount * 5 / 100; // 5% fee
        uint256 expectedNetAmount = transferAmount - expectedFee;

        console.log("--- Trigger: Transfer Amount ---");
        vm.prank(user1);
        token.transfer(ammPair, transferAmount);

        console.log("--- AFTER-Trigger State ---");
        uint256 ownerBalAfter = token.balanceOf(owner);
        uint256 user1BalAfter = token.balanceOf(user1);
        uint256 ammPairBalAfter = token.balanceOf(ammPair);
        uint256 rewardBalAfter = token.balanceOf(rewardAddress);
        uint256 totalSupplyAfter = token.totalSupply();
        
        console.log("Owner balance after:", ownerBalAfter);
        console.log("User1 balance after:", user1BalAfter);
        console.log("AMM pair balance after:", ammPairBalAfter);
        console.log("Reward address balance after:", rewardBalAfter);
        console.log("Total supply after:", totalSupplyAfter);
        
        // Compute state changes
        uint256 balanceSumAfter = ownerBalAfter + user1BalAfter + ammPairBalAfter + rewardBalAfter;
        uint256 actualFee = rewardBalAfter - rewardBalBefore;
        uint256 actualNetReceived = ammPairBalAfter - ammPairBalBefore;
        bool totalSupplyConsistent = (balanceSumAfter == totalSupplyAfter);
        bool feeCorrect = (actualFee == expectedFee);
        bool amountCorrect = (actualNetReceived == expectedNetAmount);
        bool userBalanceCorrect = (user1BalAfter == 0);
        
        // Vulnerability checks
        if (!totalSupplyConsistent) {
            console.log("Accounting ERROR: Total supply inconsistency detected");
            console.log("Vulnerability Exists: Accounting validation failed");
            return;
        }
        if (!feeCorrect) {
            console.log("Fee ERROR: Expected fee %s, actual fee collected %s",
                expectedFee, actualFee);
            console.log("Vulnerability Exists: Fee allocation error");
            return;
        }
        if (!amountCorrect) {
            console.log("Transfer ERROR: Expected AMM received %s, actual received %s",
                expectedNetAmount, actualNetReceived);
            console.log("Vulnerability Exists: Transfer amount incorrect");
            return;
        }
        if (!userBalanceCorrect) {
            console.log("Balance ERROR: Expected user1 balance 0, actual %s",
                user1BalAfter);
            console.log("Vulnerability Exists: Sender balance incorrect");
            return;
        }
        
        // Final verdict
        console.log("SUCCESS: All accounting states consistent with expectations");
        console.log("Vulnerability not Exist: Accounting validation passed");
    }
}