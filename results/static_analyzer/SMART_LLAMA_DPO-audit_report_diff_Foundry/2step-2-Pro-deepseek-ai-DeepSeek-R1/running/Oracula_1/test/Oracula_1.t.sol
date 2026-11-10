// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Oracula.sol";

// Mock contracts to simulate PancakeSwap interfaces
contract MockPancakeRouter {
    function factory() external pure returns (address) {
        return address(0x1000);
    }
    
    function WETH() external pure returns (address) {
        return address(0xDEAD);
    }
}

contract MockPancakeFactory {
    function createPair(address, address) external returns (address) {
        return address(0xBEEF);
    }
}

contract OraculaFeeOnTransferTest is Test {
    Oracula token;
    address alice;
    address bob;
    address devAddress;
    address rewardAddress;

    struct Balances {
        uint256 alice;
        uint256 bob;
        uint256 dev;
        uint256 reward;
        uint256 burn;
        uint256 totalSupply;
    }

    function setUp() public {
        alice = address(0x1);
        bob = address(0x2);
        devAddress = address(0xDEAD);
        rewardAddress = address(0xBEEF);
        
        // Deploy mocks and setup environment
        MockPancakeFactory mockFactory = new MockPancakeFactory();
        MockPancakeRouter mockRouter = new MockPancakeRouter();
        
        // Override hardcoded addresses with mock code
        vm.etch(address(0x1000), address(mockFactory).code);
        vm.etch(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), address(mockRouter).code);
        
        // Deploy token with initial 0 fees
        token = new Oracula(
            devAddress,
            rewardAddress,
            0,    // burnFee
            0,    // devFee
            0     // rewardFee
        );
        
        // Set actual fees (total 30 basis points)
        token.changeAllFees(
            10,   // burnFee (0.1%)
            10,   // devFee (0.1%)
            10    // rewardFee (0.1%)
        ); 
        
        // Fund Alice with tokens to test
        uint256 decimals = token.decimals();
        uint256 transferAmount = 1000 * 10 ** decimals;
        token.transfer(alice, transferAmount);
    }

    function testTransferDoesNotCollectFees() public {
        // Verify fees are set correctly
        assertEq(token.getSumOfFees(), 30, "Fees not set");
        
        console.log("--- BEFORE-Trigger Transfer ---");
        // Capture initial state in struct
        Balances memory before = Balances(
            token.balanceOf(alice),
            token.balanceOf(bob),
            token.balanceOf(devAddress),
            token.balanceOf(rewardAddress),
            token.balanceOf(address(0)),
            token.totalSupply()
        );

        console.log("Alice balance:    ", before.alice);
        console.log("Bob balance:      ", before.bob);
        console.log("Dev balance:      ", before.dev);
        console.log("Reward balance:   ", before.reward);
        console.log("Burn balance:     ", before.burn);
        console.log("Total supply:     ", before.totalSupply);
        console.log("");

        console.log("--- Trigger Transfer ---");
        // Alice transfers to Bob
        vm.prank(alice);
        token.transfer(bob, before.alice);
        
        console.log("--- AFTER-Trigger Transfer ---");
        // Capture post-transfer state in struct
        Balances memory afterTransfer = Balances(
            token.balanceOf(alice),
            token.balanceOf(bob),
            token.balanceOf(devAddress),
            token.balanceOf(rewardAddress),
            token.balanceOf(address(0)),
            token.totalSupply()
        );

        console.log("Alice balance:    ", afterTransfer.alice);
        console.log("Bob balance:      ", afterTransfer.bob);
        console.log("Dev balance:      ", afterTransfer.dev);
        console.log("Reward balance:   ", afterTransfer.reward);
        console.log("Burn balance:     ", afterTransfer.burn);
        console.log("Total supply:     ", afterTransfer.totalSupply);
        console.log("");
        
        // Calculate fee differences
        uint256 feeDev = afterTransfer.dev - before.dev;
        uint256 feeReward = afterTransfer.reward - before.reward;
        uint256 feeBurn = afterTransfer.burn - before.burn;
        uint256 totalFees = feeDev + feeReward + feeBurn;
        bool feesCollected = feeDev > 0 || feeReward > 0 || feeBurn > 0;
        
        console.log("Dev fee change:   ", feeDev);
        console.log("Reward fee change:", feeReward);
        console.log("Burn fee change:  ", feeBurn);
        console.log("Total fee change: ", totalFees);
        console.log("Fee collected?    ", feesCollected ? "YES" : "NO");
        console.log("");

        // Final vulnerability verdict based on fee collection
        if (!feesCollected) {
            console.log("Vulnerability Exists: No fees were collected on transfer despite fee settings");
        } else {
            console.log("Vulnerability not Exist: Fees were collected as expected");
        }

        // Additional validation checks
        assertEq(afterTransfer.alice, 0, "Alice balance incorrect");
        assertEq(afterTransfer.bob, before.bob + before.alice, "Bob missing funds");
        assertEq(afterTransfer.dev, before.dev, "Dev fee collected");
        assertEq(afterTransfer.reward, before.reward, "Reward fee collected");
        assertEq(afterTransfer.burn, before.burn, "Burn fee collected");
    }
}