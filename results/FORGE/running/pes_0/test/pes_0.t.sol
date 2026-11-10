// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PEPESMOKING.sol";

contract MockFactory {
    address public pair;

    constructor(address _pair) {
        pair = _pair;
    }

    function createPair(address, address) external returns (address) {
        return pair;
    }
}

contract MockWETH {}

contract MockRouter {
    address public factory;
    address public WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract PEPESMOKINGBlacklistTest is Test {
    PEPESMOKING token;
    address owner = address(0x1);
    address alice = address(0x2);
    address bob = address(0x3);
    address constant UNISWAP_ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address mockFactory;
    address mockWETH;
    address mockPair = address(0xABC);

    function setUp() public {
        // Deploy mock contracts
        mockWETH = address(new MockWETH());
        mockFactory = address(new MockFactory(mockPair));
        address tempRouter = address(new MockRouter(mockFactory, mockWETH));
        
        // Set up mock router
        vm.etch(UNISWAP_ROUTER_ADDR, tempRouter.code);
        bytes32 slot0 = bytes32(uint256(0));
        bytes32 slot1 = bytes32(uint256(1));
        vm.store(UNISWAP_ROUTER_ADDR, slot0, bytes32(uint256(uint160(mockFactory))));
        vm.store(UNISWAP_ROUTER_ADDR, slot1, bytes32(uint256(uint160(mockWETH))));
        
        // Deploy token
        vm.startPrank(owner);
        token = new PEPESMOKING();
        
        // Disable all fee mechanisms
        token.setSwapAndLiquifyEnabled(false);
        token.setFeePercent(0, 0, 0, 0);
        
        // Full permission token settings
        uint256 supply = token.totalSupply();
        token.setMaxTxAmount(supply);
        token.setMaxWalletLimit(supply);
        
        // Exclude test participants from fees
        token.excludeFromFee(alice);
        token.excludeFromFee(bob);
        
        // Fund Alice
        token.transfer(alice, 1000 * 10 ** token.decimals());
        vm.stopPrank();
    }

    function testBlacklistBlocksTransactions() public {
        uint256 transferAmount = 100 * 10 ** token.decimals();
        
        console.log("--- BEFORE-Blacklist ---");
        // Check initial state
        uint256 bobInitialBalance = token.balanceOf(bob);
        console.log("Bob initial balance: ", bobInitialBalance);
        
        // Execute first transfer (should succeed)
        vm.prank(alice);
        token.transfer(bob, transferAmount);
        
        uint256 bobBalanceAfterTransfer = token.balanceOf(bob);
        console.log("Bob balance after first transfer: ", bobBalanceAfterTransfer);
        
        uint256 balanceChange1 = bobBalanceAfterTransfer - bobInitialBalance;
        console.log("Balance change after first transfer: ", balanceChange1);

        console.log("--- Trigger Blacklist ---");
        // Blacklist Alice
        vm.prank(owner);
        token.blackListAccount(alice);
        assertTrue(token.isBlackListed(alice));
        console.log("Alice blacklisted");

        console.log("--- AFTER-Blacklist ---");
        uint256 bobPreBlockedTransferBalance = token.balanceOf(bob);
        console.log("Bob balance before blocked transfer: ", bobPreBlockedTransferBalance);
        
        // Attempt blocked transfer
        vm.expectRevert();
        vm.prank(alice);
        token.transfer(bob, transferAmount);
        console.log("Blocked transfer reverted (as expected)");
        
        uint256 bobPostBlockedTransferBalance = token.balanceOf(bob);
        console.log("Bob balance after blocked transfer: ", bobPostBlockedTransferBalance);
        
        uint256 balanceChange2 = bobPostBlockedTransferBalance - bobPreBlockedTransferBalance;
        console.log("Balance change after blocked transfer: ", balanceChange2);
        
        // Vulnerability validation
        if (balanceChange1 > 0 && balanceChange2 == 0) {
            console.log("Vulnerability Exists: Blacklist successfully blocked transfer resulting in 0 balance change");
        } else {
            console.log("Vulnerability not Exist: Blacklist failed to block transfer as shown by balance change");
        }
    }
}