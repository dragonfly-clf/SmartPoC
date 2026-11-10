// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/RebaseDividendToken.sol";

contract MockToken {
    mapping(address => uint256) public balanceOf;
    
    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

    function transfer(address /* to */, uint256 /* amount */) external returns (bool) {
        // Always return false to simulate malicious token behavior
        return false;
    }
}

contract RebaseDividendToken_UncheckedTransfer_Test is Test {
    RebaseDividendToken public token;
    MockToken public maliciousToken;
    address constant BSC_UNISWAP_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address owner = makeAddr("owner");
    address fundAddress; // To store token's fund address

    function setUp() public {
        address mockFactoryAddress = address(0x123);
        address mockPairAddress = address(0x456);
        
        // Mock Uniswap router/factory calls
        vm.mockCall(
            BSC_UNISWAP_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactoryAddress)
        );
        vm.mockCall(
            mockFactoryAddress,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPairAddress)
        );
        
        // Create token contract in owner context
        vm.prank(owner);
        token = new RebaseDividendToken();
        
        maliciousToken = new MockToken();
        fundAddress = token.fundAddress(); // Store fundAddress
        
        // Mint malicious tokens to token contract for transfer simulation
        maliciousToken.mint(address(token), 1000);
    }

    function test_UncheckedTransferForMaliciousToken() public {
        uint amount = 1000;
        
        console.log("--- BEFORE-Trigger Balances ---");
        uint256 tokenContractBalanceBefore = maliciousToken.balanceOf(address(token));
        uint256 fundAddressBalanceBefore = maliciousToken.balanceOf(fundAddress);
        console.log("Token contract balance (before):", tokenContractBalanceBefore);
        console.log("Fund address balance (before):", fundAddressBalanceBefore);

        console.log("--- Trigger: claimToken ---");
        // Execute the claimToken function with malicious token
        token.claimToken(address(maliciousToken), amount);
        
        console.log("--- AFTER-Trigger Balances ---");
        uint256 tokenContractBalanceAfter = maliciousToken.balanceOf(address(token));
        uint256 fundAddressBalanceAfter = maliciousToken.balanceOf(fundAddress);
        console.log("Token contract balance (after):", tokenContractBalanceAfter);
        console.log("Fund address balance (after):", fundAddressBalanceAfter);

        // Vulnerability verification: Balances should remain unchanged
        bool balancesUnchanged = 
            (tokenContractBalanceBefore == tokenContractBalanceAfter) &&
            (fundAddressBalanceBefore == fundAddressBalanceAfter);
        console.log("Balances unchanged:", balancesUnchanged ? "YES" : "NO");
        
        // Final vulnerability verdict
        if (balancesUnchanged) {
            console.log("Vulnerability Exists: Transfer failed but state was not reverted");
        } else {
            console.log("Vulnerability not Exist: State changed as expected");
        }
    }
}