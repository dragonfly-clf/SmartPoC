// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FeelrToken.sol";

contract MockDexFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x2222222222222222222222222222222222222222);
    }
}

contract MockDexRouter {
    address public immutable factoryAddr;

    constructor(address _factory) {
        factoryAddr = _factory;
    }

    function factory() external view returns (address) {
        return factoryAddr;
    }

    function WETH() external pure returns (address) {
        return address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
}

contract RevertingReceiver {
    receive() external payable {
        revert("ETH transfer reverted");
    }
}

contract FeelrTokenTest is Test {
    FeelrToken feelrToken;
    RevertingReceiver revertingReceiver;
    address owner = makeAddr("owner");
    uint256 initialEthBalance = 1 ether;

    function setUp() public {
        // Create mock factory
        MockDexFactory mockFactory = new MockDexFactory();

        // Deploy mock router (needed for bytecode)
        MockDexRouter mockRouter = new MockDexRouter(address(mockFactory));
        
        // Put mock router code at hardcoded address (0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D)
        bytes memory mockCode = address(mockRouter).code;
        address routerAddr = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        vm.etch(routerAddr, mockCode);

        // Deploy token
        vm.startPrank(owner);
        feelrToken = new FeelrToken();
        vm.stopPrank();

        // Fund token contract
        vm.deal(address(feelrToken), initialEthBalance);

        // Deploy reverting receiver
        revertingReceiver = new RevertingReceiver();
    }

    function test_removeStuckEth_failsWhenReceiverReverts() public {
        // Pre-trigger state
        uint256 contractBalanceBefore = address(feelrToken).balance;
        uint256 receiverBalanceBefore = address(revertingReceiver).balance;
        console2.log("--- BEFORE-Trigger removeStuckEth (Failure Case) ---");
        console2.log("Contract ETH balance (before):", contractBalanceBefore);
        console2.log("Receiver ETH balance (before):", receiverBalanceBefore);

        console2.log("--- Trigger removeStuckEth on Reverting Receiver ---");
        
        // Attempt to send ETH to reverting receiver
        vm.prank(owner);
        vm.expectRevert();
        feelrToken.removeStuckEth(address(revertingReceiver));

        // Post-trigger state
        uint256 contractBalanceAfter = address(feelrToken).balance;
        uint256 receiverBalanceAfter = address(revertingReceiver).balance;
        console2.log("--- AFTER-Trigger removeStuckEth ---");
        console2.log("Contract ETH balance (after):", contractBalanceAfter);
        console2.log("Receiver ETH balance (after):", receiverBalanceAfter);

        // State changes verification
        console2.log("--- Verification ---");
        assertEq(contractBalanceAfter, contractBalanceBefore);
        assertEq(receiverBalanceAfter, receiverBalanceBefore);
        bool ethLockDetected = (contractBalanceAfter == contractBalanceBefore) && 
                               (receiverBalanceAfter == receiverBalanceBefore);
        
        if (ethLockDetected) {
            console2.log("Vulnerability Exists: ETH remains locked in contract after failed transfer");
        } else {
            console2.log("Vulnerability not Exist: ETH successfully removed despite receiver revert");
        }
    }

    function test_removeStuckEth_succeedsWithValidReceiver() public {
        address validReceiver = makeAddr("validReceiver");
        
        // Pre-trigger state
        uint256 contractBalanceBefore = address(feelrToken).balance;
        uint256 receiverBalanceBefore = validReceiver.balance;
        console2.log("--- BEFORE-Trigger removeStuckEth (Success Case) ---");
        console2.log("Contract ETH balance (before):", contractBalanceBefore);
        console2.log("Receiver ETH balance (before):", receiverBalanceBefore);

        console2.log("--- Trigger removeStuckEth on Valid Receiver ---");
        
        // Send ETH successfully
        vm.prank(owner);
        feelrToken.removeStuckEth(validReceiver);

        // Post-trigger state
        uint256 contractBalanceAfter = address(feelrToken).balance;
        uint256 receiverBalanceAfter = validReceiver.balance;
        console2.log("--- AFTER-Trigger removeStuckEth ---");
        console2.log("Contract ETH balance (after):", contractBalanceAfter);
        console2.log("Receiver ETH balance (after):", receiverBalanceAfter);

        // State changes verification
        console2.log("--- Verification ---");
        assertEq(validReceiver.balance, receiverBalanceBefore + initialEthBalance);
        assertEq(address(feelrToken).balance, 0);
        bool ethRemovedSuccessfully = (contractBalanceAfter == 0) && 
                                      (receiverBalanceAfter == receiverBalanceBefore + initialEthBalance);
        
        if (ethRemovedSuccessfully) {
            console2.log("Vulnerability not Exist: ETH successfully transferred to receiver");
        } else {
            console2.log("Vulnerability Exists: ETH removal failed despite valid receiver");
        }
    }
}