// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SantaCoin.sol";

contract MaliciousToken {
    mapping(address => uint256) public balanceOf;
    
    function mint(address account, uint256 amount) external {
        balanceOf[account] = amount;
    }
    
    function transfer(address, uint256) external pure returns (bool) {
        return false; // Always fail transfer
    }
}

contract MockWETH {
    // Minimal implementation for WETH
}

contract MockPair {
    // Minimal implementation for Pair
}

contract MockFactory {
    address public immutable pair;

    constructor(address _pair) {
        pair = _pair;
    }

    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockRouter {
    address public factory;
    address public WETH;
    
    function initialize(address _factory, address _weth) public {
        factory = _factory;
        WETH = _weth;
    }
}

contract SantaCoin_ClaimStuckTokensTest is Test {
    SantaCoin public santaCoin;
    MaliciousToken public maliciousToken;
    uint256 constant balanceAmount = 1000e18;
    
    address constant originalOwner = 0xc70327c3C21F6B3922f3a843B9fF77677140bfee;
    address constant routerAddr = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    function setUp() public {
        // Set chain ID to Ethereum mainnet
        vm.chainId(1);
        
        // Deploy mock tokens and contracts
        MockWETH mockWETH = new MockWETH();
        MockPair mockPair = new MockPair();
        MockFactory mockFactory = new MockFactory(address(mockPair));
        
        // Deploy mock router and initialize at fixed address
        MockRouter mockRouter = new MockRouter();
        vm.etch(routerAddr, address(mockRouter).code);
        MockRouter(routerAddr).initialize(address(mockFactory), address(mockWETH));
        
        // Deploy main contracts
        santaCoin = new SantaCoin();
        maliciousToken = new MaliciousToken();
        
        // Fund SantaCoin with malicious tokens
        maliciousToken.mint(address(santaCoin), balanceAmount);
    }

    function test_ClaimStuckTokens_UncheckedTransfer() public {
        console.log("--- BEFORE-Trigger State Check ---");
        // Record initial token balances
        uint256 santaCoinBalanceBefore = maliciousToken.balanceOf(address(santaCoin));
        uint256 ownerBalanceBefore = maliciousToken.balanceOf(originalOwner);
        console.log("SantaCoin contract token balance (before):", santaCoinBalanceBefore);
        console.log("Owner token balance (before):", ownerBalanceBefore);
        assertEq(santaCoinBalanceBefore, balanceAmount, "Initial tokens not minted correctly");
        assertEq(ownerBalanceBefore, 0, "Owner should start with zero tokens");

        console.log("\n--- Trigger: Calling claimStuckTokens ---");
        // Execute function as owner
        vm.prank(originalOwner);
        santaCoin.claimStuckTokens(address(maliciousToken));
        console.log("Trigger executed without revert");

        console.log("\n--- AFTER-Trigger State Check ---");
        // Capture token balances after function execution
        uint256 santaCoinBalanceAfter = maliciousToken.balanceOf(address(santaCoin));
        uint256 ownerBalanceAfter = maliciousToken.balanceOf(originalOwner);
        console.log("SantaCoin contract token balance (after):", santaCoinBalanceAfter);
        console.log("Owner token balance (after):", ownerBalanceAfter);
        assertEq(santaCoinBalanceAfter, balanceAmount, "Token should remain in contract after failed transfer");
        assertEq(ownerBalanceAfter, 0, "Owner should not receive tokens when transfer fails");

        // Vulnerability verification logic
        console.log("\n--- Vulnerability Analysis ---");
        bool stateUnchanged = (santaCoinBalanceAfter == santaCoinBalanceBefore) && 
                            (ownerBalanceAfter == ownerBalanceBefore);
        if (stateUnchanged) {
            console.log("LOGICAL VERDICT: Balances unchanged - Function ignored failed transfer");
            console.log("Vulnerability Exists: The claimStuckTokens function did not revert on failed token transfer, allowing state to remain unmodified");
        } else {
            console.log("LOGICAL VERDICT: Balances changed unexpectedly");
            console.log("Vulnerability not Exist: The token transfer unexpectedly succeeded or state modified");
        }
    }
}