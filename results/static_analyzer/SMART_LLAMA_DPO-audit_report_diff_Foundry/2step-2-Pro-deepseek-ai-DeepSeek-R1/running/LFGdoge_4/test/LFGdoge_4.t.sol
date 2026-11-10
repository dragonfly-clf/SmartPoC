// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LFGdoge.sol";

contract MockFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair) {
        return address(0x123);
    }
}

contract MockRouter {
    address public immutable factory;
    
    constructor(address _factory) {
        factory = _factory;
    }

    function WETH() external pure returns (address) {
        return address(0x456);
    }
}

contract LFGdogePrivilegeTest is Test {
    LFGdoge public token;
    address owner = address(1);
    address user = address(2);
    address payable newMarketingWallet = payable(address(0xDEAD));
    address constant HARDCODED_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Configure mock Uniswap router for deployment
        MockFactory factory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(factory));
        vm.etch(HARDCODED_ROUTER, address(mockRouter).code);

        // Deploy token
        vm.startPrank(owner);
        token = new LFGdoge();
        vm.stopPrank();
    }

    function test_OwnerArbitraryMarketingWalletChange() public {
        // Pre-state: Verify marketingWallet not set to test address
        address initialWallet = token.marketingWalletAddress();
        console.log("--- BEFORE setting Marketing Wallet ---");
        console.log("Current Marketing Wallet:", initialWallet);
        console.log("Expected New Wallet:", newMarketingWallet);
        
        // Check current wallet doesn't match new one
        if(initialWallet != newMarketingWallet) {
            console.log("Precondition: Wallet NOT equal - OK");
        }

        console.log("--- Trigger: setMarketingWalletAddress ---");
        vm.prank(owner);
        token.setMarketingWalletAddress(newMarketingWallet);

        console.log("--- AFTER setting Marketing Wallet ---");
        address updatedWallet = token.marketingWalletAddress();
        console.log("Updated Marketing Wallet:", updatedWallet);

        // Determine vulnerability existence
        if(updatedWallet == newMarketingWallet) {
            console.log("Result: Wallet changed to arbitrary address");
            console.log("Vulnerability Exists: Owner can arbitrarily change marketing wallet");
        } else {
            console.log("Result: Wallet change unsuccessful");
            console.log("Vulnerability not Exist: Marketing wallet remains unchanged");
        }
    }

    function test_OwnerSetExcessiveTxLimit() public {
        uint256 decimals = token.decimals();
        uint256 excessiveAmount = 1_000_000_000_000 * (10 ** decimals);

        console.log("--- BEFORE setting MaxTxAmount ---");
        uint256 initialMaxTx = token._maxTxAmount();
        console.log("Current Max Tx Amount: %s tokens", initialMaxTx);
        console.log("Excessive Limit to set: %s tokens", excessiveAmount);

        console.log("--- Trigger: setMaxTxAmount ---");
        vm.prank(owner);
        token.setMaxTxAmount(excessiveAmount);

        console.log("--- AFTER setting MaxTxAmount ---");
        uint256 updatedMaxTx = token._maxTxAmount();
        console.log("Updated Max Tx Amount: %s tokens", updatedMaxTx);

        // Determine vulnerability existence
        if(updatedMaxTx == excessiveAmount) {
            console.log("Result: Successfully set extreme tx limit");
            console.log("Vulnerability Exists: Owner can bypass reasonable maxTxAmount limits");
        } else {
            console.log("Result: Failed to set tx limit");
            console.log("Vulnerability not Exist: MaxTxAmount remains within safe limits");
        }
    }

    // Non-owner test remains unchanged - state verification not required
    function test_NonOwnerFailsToSetParameters() public {
        // Verify onlyOwner modifier prevents non-owner access
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(user);
        token.setMaxTxAmount(1 ether);

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(user);
        token.setSwapAndLiquifyEnabled(true);

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(user);
        token.setSwapAndLiquifyByLimitOnly(false);

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(user);
        token.setWalletLimit(1_000_000 ether);

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(user);
        token.setNumTokensBeforeSwap(1_000_000_000);
    }
}