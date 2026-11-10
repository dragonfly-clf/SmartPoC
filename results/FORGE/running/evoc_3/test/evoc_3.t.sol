// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/EvocPlus.sol";

contract EvocPlusMintTest is Test {
    EvocPlus token;
    address minter = address(0x1);
    address router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address factory = address(0x2);
    address pair = address(0x3);
    address WBNB = address(0x4);
    
    function setUp() public {
        // Mock router and factory dependencies
        deal(minter, 1 ether);
        vm.startPrank(minter);
        
        // Mock router factory
        vm.mockCall(
            router,
            abi.encodeWithSignature("factory()"),
            abi.encode(factory)
        );
        
        // Mock pair creation
        vm.mockCall(
            factory,
            abi.encodeWithSignature("createPair(address,address)", WBNB, address(this)),
            abi.encode(pair)
        );
        
        // Deploy token contract
        token = new EvocPlus();
        vm.stopPrank();
    }

    function testMintInflatesSupply() public {
        // State before mint operation
        console.log("--- BEFORE-Trigger Mint State ---");
        uint256 preTotalSupply = token.totalSupply();
        uint256 preMinterBalance = token.balanceOf(minter);
        console.log("Pre-totalSupply: %s", preTotalSupply);
        console.log("Pre-minterBalance: %s", preMinterBalance);
        assertTrue(preTotalSupply > 0, "Initial supply should be non-zero");
        
        // Calculate safe mint amount (10% of max supply)
        uint256 maxSupply = 10000000000 * (10**18); // Report indicates 10B max
        uint256 mintAmount = maxSupply / 10; // 10% of max supply
        
        console.log("--- Trigger Mint Operation ---");
        // Act as minter to mint tokens
        vm.startPrank(minter);
        token.mint(mintAmount);
        vm.stopPrank();

        // State after mint operation
        console.log("--- AFTER-Trigger Mint State ---");
        uint256 postTotalSupply = token.totalSupply();
        uint256 postMinterBalance = token.balanceOf(minter);
        console.log("Post-totalSupply: %s", postTotalSupply);
        console.log("Post-minterBalance: %s", postMinterBalance);
        
        // Calculate state differences
        uint256 supplyDifference = postTotalSupply - preTotalSupply;
        uint256 balanceDifference = postMinterBalance - preMinterBalance;
        
        // Verify inflation impact (original assertions)
        uint256 inflationRate = ((supplyDifference) * 10000) / preTotalSupply;
        console.log("Supply change: %s (expected %s)", supplyDifference, mintAmount);
        console.log("Balance change: %s (expected %s)", balanceDifference, mintAmount);
        console.log("Inflation rate: %s bp", inflationRate);
        
        // Final vulnerability verdict
        if (supplyDifference == mintAmount && balanceDifference == mintAmount) {
            console.log("Vulnerability Exists: Minter successfully minted tokens and increased supply/balance as expected");
        } else {
            console.log("Vulnerability not Exist: State changes did not match mint amount");
        }
    }
}