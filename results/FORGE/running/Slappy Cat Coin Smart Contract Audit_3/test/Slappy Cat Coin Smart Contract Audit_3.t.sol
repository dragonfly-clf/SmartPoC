// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SlappyCat.sol";

contract MockWETH {
    fallback() external payable {}
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0xdEaD);
    }
}

contract MockRouter {
    address public factory;
    address public WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract RevertingReceiver {
    bool public receivedFunds = false;
    
    receive() external payable {
        receivedFunds = true;
        revert("ETH transfers not allowed");
    }
}

contract SlappyCatTest is Test {
    SlappyCat token;
    RevertingReceiver receiver;
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    uint256 constant TEST_AMOUNT = 1 ether;
    address owner = makeAddr("owner");
    address mockFactory;
    address mockWETH;

    function setUp() public {
        // Set up environment as BSC mainnet
        vm.chainId(56);
        vm.startPrank(owner);
        
        // Deploy mocks
        mockWETH = address(new MockWETH());
        mockFactory = address(new MockFactory());
        
        // Create and initialize mock router
        MockRouter router = new MockRouter(mockFactory, mockWETH);
        
        // Mock Router at BSC address
        vm.etch(ROUTER_ADDRESS, address(router).code);
        
        // Initialize storage slots for router
        bytes32 factorySlot = bytes32(uint256(0));
        bytes32 wethSlot = bytes32(uint256(1));
        vm.store(ROUTER_ADDRESS, factorySlot, bytes32(uint256(uint160(mockFactory))));
        vm.store(ROUTER_ADDRESS, wethSlot, bytes32(uint256(uint160(mockWETH))));
        
        // Deploy token contract
        token = new SlappyCat();
        
        // Deploy reverting receiver
        receiver = new RevertingReceiver();
        
        vm.stopPrank();
    }

    function testEthTransferFailsSilently() public {
        // Fund token contract with ETH
        payable(address(token)).transfer(TEST_AMOUNT);
        assertEq(address(token).balance, TEST_AMOUNT, "Initial ETH balance incorrect");
        
        // Transfer ownership to receiver
        vm.prank(owner);
        token.transferOwnership(address(receiver));
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 tokenBalanceBefore = address(token).balance;
        uint256 receiverBalanceBefore = address(receiver).balance;
        bool receivedBefore = receiver.receivedFunds();
        console.log("Token contract ETH balance:    ", tokenBalanceBefore);
        console.log("Receiver contract ETH balance: ", receiverBalanceBefore);
        console.log("Receiver receivedFunds status: ", receivedBefore);

        console.log("\n--- Trigger Action: claimStuckTokens ---");
        // Attempt to transfer ETH to malicious receiver
        vm.prank(address(receiver));
        token.claimStuckTokens(address(0));

        console.log("\n--- AFTER-Trigger State ---");
        uint256 tokenBalanceAfter = address(token).balance;
        uint256 receiverBalanceAfter = address(receiver).balance;
        bool receivedAfter = receiver.receivedFunds();
        console.log("Token contract ETH balance:    ", tokenBalanceAfter);
        console.log("Receiver contract ETH balance: ", receiverBalanceAfter);
        console.log("Receiver receivedFunds status: ", receivedAfter);

        // Differential comparison
        console.log("\n--- Differential Result ---");
        bool tokenBalanceUnchanged = tokenBalanceAfter == tokenBalanceBefore;
        bool receiverBalanceUnchanged = receiverBalanceAfter == receiverBalanceBefore;
        bool receivedStatusUnchanged = receivedAfter == receivedBefore;
        bool statusRemainsFalse = !receivedAfter;
        
        console.log("Token balance unchanged:      %s", tokenBalanceUnchanged ? "YES" : "NO");
        console.log("Receiver balance unchanged:   %s", receiverBalanceUnchanged ? "YES" : "NO");
        console.log("ReceivedFunds status false:   %s", statusRemainsFalse ? "YES" : "NO");
        
        // Final vulnerability verdict
        if (tokenBalanceUnchanged && receiverBalanceUnchanged && statusRemainsFalse) {
            console.log("Vulnerability Exists: Silent failure of ETH transfer confirmed (no state change)");
        } else {
            console.log("Vulnerability not Exist: Unexpected state change detected");
        }

        // Original assertions (unchanged)
        assertEq(address(token).balance, tokenBalanceBefore, "Token contract ETH balance should remain unchanged");
        assertEq(address(receiver).balance, receiverBalanceBefore, "Receiver ETH balance should remain zero");
        assertFalse(receiver.receivedFunds(), "Receiver should not have accepted ETH");
    }
}