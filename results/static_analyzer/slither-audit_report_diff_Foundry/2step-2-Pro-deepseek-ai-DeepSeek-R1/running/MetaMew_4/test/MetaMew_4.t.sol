// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MetaMew.sol";

contract MaliciousToken {
    mapping(address => uint256) public balanceOf;

    constructor(uint256 initialSupply) {
        balanceOf[msg.sender] = initialSupply;
    }

    // Always returns false without reverting
    function transfer(address, uint256) public pure returns (bool) {
        return false;
    }
}

contract MetaMewWithdrawTest is Test {
    MetaMew public metaMew;
    MaliciousToken public maliciousToken;
    address owner = address(0x1);
    address constant HARDCODED_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Create mock addresses for router, factory, and WETH
        address mockFactory = address(0xF4c7);
        address mockWETH = address(0x1E7);
        address mockLiquidityPair = address(0x8624);
        
        // Mock router factory() call
        vm.mockCall(
            HARDCODED_ROUTER, 
            abi.encodeWithSignature("factory()"), 
            abi.encode(mockFactory)
        );
        
        // Mock router WETH() call
        vm.mockCall(
            HARDCODED_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Mock factory createPair() call
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockLiquidityPair)
        );

        // Deploy MetaMew with mocked dependencies
        vm.startPrank(owner);
        metaMew = new MetaMew();
        vm.stopPrank();

        // Deploy malicious token and fund MetaMew contract
        maliciousToken = new MaliciousToken(1000 ether);
        deal(address(maliciousToken), owner, 500 ether);
        deal(address(maliciousToken), address(metaMew), 500 ether);
    }

    function testWithdrawForeignTokenIgnoresFailure() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 contractBalanceBefore = maliciousToken.balanceOf(address(metaMew));
        uint256 ownerBalanceBefore = maliciousToken.balanceOf(owner);
        console.log("Contract token balance (before):", contractBalanceBefore);
        console.log("Owner token balance (before):", ownerBalanceBefore);

        console.log("--- Trigger WithdrawForeignToken ---");
        vm.prank(owner);
        metaMew.withdrawForeignToken(address(maliciousToken));
        
        console.log("--- AFTER-Trigger State ---");
        uint256 contractBalanceAfter = maliciousToken.balanceOf(address(metaMew));
        uint256 ownerBalanceAfter = maliciousToken.balanceOf(owner);
        console.log("Contract token balance (after):", contractBalanceAfter);
        console.log("Owner token balance (after):", ownerBalanceAfter);

        // Check that balances remain unchanged
        assertEq(contractBalanceAfter, 500 ether, "Contract balance unchanged");
        assertEq(ownerBalanceAfter, 500 ether, "Owner balance unchanged");
        
        // Determine vulnerability existence
        bool vulnerabilityExists = 
            (contractBalanceAfter == contractBalanceBefore) && 
            (ownerBalanceAfter == ownerBalanceBefore) && 
            (contractBalanceAfter > 0);
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Token balances unchanged after failure state but transaction completed");
        } else {
            console.log("Vulnerability not Exist: Token balances changed after withdrawal operation");
        }
    }
}