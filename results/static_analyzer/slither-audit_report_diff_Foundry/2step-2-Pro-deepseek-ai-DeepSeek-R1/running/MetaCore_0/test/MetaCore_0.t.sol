// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MetaCore.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0xdead);
    }
}

contract MockWETH {
    function deposit() external payable {}
    function withdraw(uint) external {}
}

contract MockUniswapV2Router02 {
    address public factory;
    address public WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract MetaCoreArbitrarySendTest is Test {
    MetaCore public metaCore;
    address public owner = address(0x1);
    address public arbitraryRecipient = address(0x2);
    address public marketingWallet = address(0x3);
    address public mockFactory = address(new MockUniswapV2Factory());
    address public mockWETH = address(new MockWETH());
    address public mockRouter;
    uint8 public stakingReleaseIntervalDays = 7;
    uint256 public amount = 1 ether;

    function setUp() public {
        mockRouter = address(new MockUniswapV2Router02(mockFactory, mockWETH));
        
        vm.startPrank(owner);
        metaCore = new MetaCore(marketingWallet, stakingReleaseIntervalDays, mockRouter);
        vm.stopPrank();
        
        // Fund the contract with Ether
        vm.deal(address(metaCore), amount);
    }

    function testArbitraryEthTransfer() public {
        // Before: Capture initial balances
        uint256 initialContractBalance = address(metaCore).balance;
        uint256 initialRecipientBalance = arbitraryRecipient.balance;
        console.log("--- BEFORE-Trigger State ---");
        console.log("Contract ETH balance (initial):", initialContractBalance);
        console.log("Recipient ETH balance (initial):", initialRecipientBalance);
        console.log("");

        // Trigger: Attempt withdrawal by owner
        console.log("--- Trigger Action ---");
        console.log("Calling: withdraw(%s, %s ETH)", arbitraryRecipient, amount);
        vm.prank(owner);
        metaCore.withdraw(payable(arbitraryRecipient), amount);
        console.log("");

        // After: Capture balances after withdrawal
        uint256 finalContractBalance = address(metaCore).balance;
        uint256 finalRecipientBalance = arbitraryRecipient.balance;
        console.log("--- AFTER-Trigger State ---");
        console.log("Contract ETH balance (final):", finalContractBalance);
        console.log("Recipient ETH balance (final):", finalRecipientBalance);
        console.log("");

        // Calculate state changes
        uint256 contractBalanceChange = initialContractBalance - finalContractBalance;
        uint256 recipientBalanceChange = finalRecipientBalance - initialRecipientBalance;
        console.log("--- Differential Results ---");
        console.log("Contract ETH change:", contractBalanceChange);
        console.log("Recipient ETH change:", recipientBalanceChange);

        // Determine vulnerability existence
        if (contractBalanceChange == amount && recipientBalanceChange == amount) {
            console.log("Vulnerability Exists: Contract owner can arbitrarily send ETH from contract");
        } else {
            console.log("Vulnerability not Exist: ETH transfer was not executed as expected");
        }
    }
}