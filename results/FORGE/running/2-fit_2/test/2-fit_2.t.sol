// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SecondToken.sol";

contract MockUniswapFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xBEEF);
    }
}

contract MockUniswapRouter {
    MockUniswapFactory private _factory;
    address private _weth;
    
    constructor() {
        _factory = new MockUniswapFactory();
        _weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
    
    function factory() external view returns (address) {
        return address(_factory);
    }
    
    function WETH() external view returns (address) {
        return _weth;
    }
}

contract MintTokenTest is Test {
    SecondToken token;
    address minter = makeAddr("minter");
    uint256 constant HUGE_MINT_AMOUNT = 1_000_000 ether;

    function setUp() public {
        // Create mock router
        MockUniswapRouter mockRouter = new MockUniswapRouter();
        
        // Deploy token contract making the test contract the admin
        token = new SecondToken(address(mockRouter), address(this));
        
        // Grant minter role directly from test contract (which is admin)
        token.grantRole(token.MINTER_ROLE(), minter);
    }

    function testMinterCanMintUnlimitedTokens() public {
        uint256 initialTotalSupply = token.totalSupply();
        uint256 minterBalanceBefore = token.balanceOf(minter);
        
        // Log states before triggering mint
        console.log("--- BEFORE Mint Trigger ---");
        console.log("TotalSupply Before Mint:", initialTotalSupply);
        console.log("Minter Balance Before Mint:", minterBalanceBefore);
        
        console.log("--- Trigger Mint Operation ---");
        // Minter mints huge amount of tokens
        vm.prank(minter);
        token.mint(minter, HUGE_MINT_AMOUNT);
        
        uint256 newTotalSupply = token.totalSupply();
        uint256 minterBalanceAfter = token.balanceOf(minter);
        
        // Log states after minting
        console.log("--- AFTER Mint Trigger ---");
        console.log("TotalSupply After Mint:", newTotalSupply);
        console.log("Minter Balance After Mint:", minterBalanceAfter);
        
        // Compute state differentials
        uint256 totalSupplyDifference = newTotalSupply - initialTotalSupply;
        uint256 mintedAmount = minterBalanceAfter - minterBalanceBefore;
        
        console.log("State Changes:");
        console.log("Total Supply Increase:", totalSupplyDifference);
        console.log("Actual Minted Amount:", mintedAmount);
        
        // Vulnerability verification logic
        if (mintedAmount == HUGE_MINT_AMOUNT && totalSupplyDifference == HUGE_MINT_AMOUNT) {
            console.log("Vulnerability Exists: Minter successfully minted unlimited tokens");
        } else {
            console.log("Vulnerability not Exist: Mint restrictions are in effect");
        }
    }
}