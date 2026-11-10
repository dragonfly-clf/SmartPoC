// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/CoinToken.sol";

contract MockUniswapRouter {
    address public immutable factory;
    
    constructor(address _factory) {
        factory = _factory;
    }
    
    function WETH() external pure returns (address) {
        return address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
}

contract MockUniswapFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234567890123456789012345678901234567890);
    }
}

contract CoinTokenTest is Test {
    CoinToken token;
    address owner = address(0x123456);
    address liquidityWallet = address(0x100);
    address devWallet = address(0x200);
    address marketingWallet = address(0x300);
    address charityWallet = address(0x400);
    
    function setUp() public {
        vm.deal(owner, 1 ether);
        
        vm.startPrank(owner);
        // Deploy mock Uniswap environment
        MockUniswapFactory mockFactory = new MockUniswapFactory();
        MockUniswapRouter mockRouter = new MockUniswapRouter(address(mockFactory));
        
        // Prepare constructor parameters
        address[6] memory addrs = [
            liquidityWallet,
            address(mockRouter),
            devWallet,
            marketingWallet,
            charityWallet,
            owner
        ];
        
        uint256[8] memory taxValues;
        
        // Deploy CoinToken
        token = new CoinToken{value: 0.1 ether}(
            "TestToken",
            "TT",
            1_000_000 ether,
            addrs,
            taxValues  // Set all taxes to 0% initially
        );
        vm.stopPrank();
    }
    
    function testSellTaxExceeds25Percent() public {
        console2.log("--- Trigger setSellTax (28%) ---");
        vm.startPrank(owner);
        try token.setSellTax(700, 700, 700, 700) {
            console2.log("Transaction succeeded without revert!");
            console2.log("Vulnerability Exists: Sell tax beyond 25%% threshold is allowed");
        } catch (bytes memory reason) {
            console2.log("Transaction reverted with reason:", 
                         reason.length == 0 ? "(no reason)" : string(reason));
            console2.log("Vulnerability not Exist: Tax limits are enforced");
        }
        vm.stopPrank(); // Ensure prank is stopped in all paths
    }
}