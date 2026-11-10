// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MarvinInu.sol";

contract MockWETH {
    // Minimal WETH mock contract
}

contract MockUniswapV2Pair {
    function sync() external {}
}

contract MockUniswapV2Factory {
    address public immutable pair;

    constructor(address _pair) {
        pair = _pair;
    }

    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockUniswapV2Router02 {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract MarvinInuTest is Test {
    MarvinInu token;
    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    uint256 transferAmount = 1000 ether; // 1000 tokens with 18 decimals
    address constant ROUTER_ADDR = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    function setUp() public {
        // Setup mock infrastructure
        MockUniswapV2Pair mockPair = new MockUniswapV2Pair();
        MockUniswapV2Factory mockFactory = new MockUniswapV2Factory(address(mockPair));
        MockWETH mockWETH = new MockWETH();
        MockUniswapV2Router02 mockRouter = new MockUniswapV2Router02(address(mockFactory), address(mockWETH));
        
        // Mock the Uniswap router at hardcoded address
        vm.etch(ROUTER_ADDR, address(mockRouter).code);

        // Deploy token contract as owner
        vm.startPrank(owner);
        token = new MarvinInu();
        
        // Configure token settings to bypass restrictions
        token.excludeFromFees(owner, true);
        token.updateMaxTxnAmount(token.totalSupply());
        token.updateMaxWalletAmount(token.totalSupply());
        token.enableTrading();
        token.disableTransferDelay();
        vm.stopPrank();

        // Fund test accounts
        vm.prank(owner);
        token.transfer(alice, transferAmount);
        vm.prank(owner);
        token.transfer(bob, transferAmount);
    }

    // Test owner can blacklist an address
    function test_OwnerCanBlacklist() public {
        uint256 halfAmount = transferAmount / 2;

        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 aliceBefore = token.balanceOf(alice);
        uint256 bobBefore = token.balanceOf(bob);
        console.log("Alice balance before:", aliceBefore);
        console.log("Bob balance before:", bobBefore);

        // Attempt transfer BEFORE blacklist (should succeed)
        vm.prank(alice);
        token.transfer(bob, halfAmount);

        uint256 aliceAfter = token.balanceOf(alice);
        uint256 bobAfter = token.balanceOf(bob);
        console.log("Transfer succeeded with no reverts");
        console.log("Alice balance after:", aliceAfter);
        console.log("Bob balance after:", bobAfter);
        assertLt(aliceAfter, aliceBefore, "Alice balance should decrease");
        assertGt(bobAfter, bobBefore, "Bob balance should increase");

        // Prepare blacklist operation
        address[] memory targets = new address[](1);
        targets[0] = alice;

        console.log("--- Trigger Blacklist ---");
        // Owner adds Alice to sniper list
        vm.prank(owner);
        token.addSnipers(targets);
        console.log("Blacklisted Alice");

        console.log("--- AFTER-Trigger Transfer ---");
        // Attempt IDENTICAL transfer AFTER blacklist (should fail)
        uint256 aliceAfterBlacklist = token.balanceOf(alice);
        uint256 bobAfterBlacklist = token.balanceOf(bob);
        console.log("Alice balance before (after blacklist):", aliceAfterBlacklist);
        console.log("Bob balance before (after blacklist):", bobAfterBlacklist);

        vm.prank(alice);
        vm.expectRevert("Sniper rejected");
        token.transfer(bob, halfAmount);
        console.log("Transfer reverted as expected");

        uint256 aliceFinal = token.balanceOf(alice);
        uint256 bobFinal = token.balanceOf(bob);
        console.log("Alice balance after:", aliceFinal);
        console.log("Bob balance after:", bobFinal);
        assertEq(aliceFinal, aliceAfterBlacklist, "Alice balance unchanged after failed transfer");
        assertEq(bobFinal, bobAfterBlacklist, "Bob balance unchanged after failed transfer");
        
        // Final verdict
        console.log("Vulnerability Exists: Owner blacklisting successfully blocks transfers");
    }

    // Test non-blacklisted address can transfer
    function test_NonBlacklistedCanTransfer() public {
        // Blacklist Alice first
        address[] memory targets = new address[](1);
        targets[0] = alice;

        vm.prank(owner);
        token.addSnipers(targets);

        // Verify Bob can transfer
        uint256 bobInitialBalance = token.balanceOf(bob);
        vm.prank(bob);
        token.transfer(owner, transferAmount / 2);

        assertEq(
            token.balanceOf(bob),
            bobInitialBalance - transferAmount / 2,
            "Bob balance should decrease"
        );
    }

    // Test owner can remove address from blacklist
    function test_OwnerCanRemoveSniper() public {
        // First blacklist Alice
        address[] memory targets = new address[](1);
        targets[0] = alice;

        vm.prank(owner);
        token.addSnipers(targets);

        // Verify Alice is blacklisted
        vm.prank(alice);
        vm.expectRevert("Sniper rejected");
        token.transfer(bob, transferAmount / 2);

        // Remove Alice from blacklist
        vm.prank(owner);
        token.removeSnipers(targets);

        // Verify Alice can transfer again
        uint256 aliceInitialBalance = token.balanceOf(alice);
        vm.prank(alice);
        token.transfer(bob, transferAmount / 2);

        assertEq(
            token.balanceOf(alice),
            aliceInitialBalance - transferAmount / 2,
            "Alice balance should decrease after unblacklisting"
        );
    }
}