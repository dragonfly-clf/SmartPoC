// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CZLunaToken.sol";

contract MockWETH {
    receive() external payable {}
    function deposit() external payable {}
    function withdraw(uint) public {}
    function transfer(address, uint) public pure returns (bool) { return true; }
    function transferFrom(address, address, uint) public pure returns (bool) { return true; }
}

contract MockUniswapV2Pair {
    function sync() external {}
}

contract MockUniswapV2Factory {
    function createPair(address, address) external returns (address) {
        return address(new MockUniswapV2Pair());
    }
}

interface IUniswapV2Router {
    function factory() external view returns (address);
    function WETH() external view returns (address);
}

contract MockRouter is IUniswapV2Router {
    address public immutable override factory;
    address public immutable override WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract CZLunaTokenBlacklistTest is Test {
    CZLunaToken token;
    address owner = address(0x1);
    address blacklistedAccount = address(0x2);
    address normalAccount = address(0x3);
    address feeExcludedAccount = address(0x4);
    uint256 constant INITIAL_BALANCE = 100 ether;

    function setUp() public {
        // Create mock Uniswap components
        MockWETH weth = new MockWETH();
        MockUniswapV2Factory factory = new MockUniswapV2Factory();
        MockRouter router = new MockRouter(address(factory), address(weth));
        
        // Override hardcoded router address
        vm.etch(0x10ED43C718714eb63d5aA57B78B54704E256024E, address(router).code);

        // Deploy token with owner
        vm.startPrank(owner);
        token = new CZLunaToken();
        
        // Enable trading
        token.setTradingStart(block.timestamp);
            
        // Exclude test accounts from fees
        token.excludeFromFee(owner);
        token.excludeFromFee(normalAccount);
        token.excludeFromFee(blacklistedAccount);
        token.excludeFromFee(feeExcludedAccount);
            
        // Fund test accounts with clean transfers (no fees)
        token.transfer(blacklistedAccount, INITIAL_BALANCE);
        token.transfer(normalAccount, INITIAL_BALANCE);
        vm.stopPrank();
    }

    function testOwnerCanBlacklistContract() public {
        // Create contract to blacklist
        console.log("--- BEFORE-Trigger Transfer ---");
        BlacklistedDummyContract dummy = new BlacklistedDummyContract();

        // Transfer funds first so dummy has balance
        vm.startPrank(owner);
        token.transfer(address(dummy), 10 ether);
        vm.stopPrank();
        console.log("Transferred initial funds to test contract");

        console.log("--- Trigger Blacklisting ---");
        // Blacklist the contract
        vm.startPrank(owner);
        address[] memory targets = new address[](1);
        targets[0] = address(dummy);
        token.addBotToBlackList(targets);
        vm.stopPrank();
        console.log("Contract blacklisted by owner");

        console.log("--- Test Transfer TO Blacklisted Contract ---");
        // Test transfers to blacklisted contract
        vm.startPrank(blacklistedAccount);
        vm.expectRevert("This address is blacklisted");
        token.transfer(address(dummy), 1 ether);
        console.log("Transfer to blacklisted contract reverted (blocked)");
        vm.stopPrank();

        console.log("--- Test Transfer FROM Blacklisted Contract ---");
        // Test transfers from blacklisted contract
        vm.startPrank(address(dummy));
        vm.expectRevert("This address is blacklisted");
        token.transfer(blacklistedAccount, 1 ether);
        console.log("Transfer from blacklisted contract reverted (blocked)");
        vm.stopPrank();
        
        console.log("Vulnerability Exists: Owner can blacklist any contract, blocking all transfers");
    }

    function testBlacklistedAddressCannotTransfer() public {
        console.log("--- BEFORE-Blacklist Transfer ---");
        // Verify initial transfer works before blacklisting
        vm.startPrank(blacklistedAccount);
        token.transfer(normalAccount, 1 ether);
        vm.stopPrank();
        console.log("Pre-blacklist transfer succeeded");
        assertEq(token.balanceOf(normalAccount), INITIAL_BALANCE + 1 ether);

        console.log("--- Trigger Blacklisting ---");
        // Blacklist account
        address[] memory targets = new address[](1);
        targets[0] = blacklistedAccount;
        vm.prank(owner);
        token.addBotToBlackList(targets);
        console.log("Account blacklisted by owner");

        console.log("--- Test Transfer FROM Blacklisted ---");
        // Verify transfers from blacklisted account fail
        vm.startPrank(blacklistedAccount);
        vm.expectRevert("This address is blacklisted");
        token.transfer(normalAccount, 1 ether);
        console.log("Transfer from blacklisted account blocked");
        vm.stopPrank();

        console.log("--- Test Transfer TO Blacklisted ---");
        // Verify transfers to blacklisted account fail
        vm.prank(normalAccount);
        vm.expectRevert("This address is blacklisted");
        token.transfer(blacklistedAccount, 1 ether);
        console.log("Transfer to blacklisted account blocked");
        
        console.log("Vulnerability Exists: Owner can block transfers to/from any address");
    }

    function testNormalTransfersAfterBlacklist() public {
        console.log("--- Trigger Blacklisting Unused Account ---");
        // Blacklist an unused account
        vm.prank(owner);
        address[] memory targets = new address[](1);
        targets[0] = feeExcludedAccount;
        token.addBotToBlackList(targets);
        console.log("Unused account blacklisted");

        uint256 transferAmount = 10 ether;
        console.log("--- Test Owner Transfer ---");
        // Transfer to normal account
        vm.prank(owner);
        token.transfer(normalAccount, transferAmount);
        console.log("Owner transfer succeeded");
        assertEq(token.balanceOf(normalAccount), INITIAL_BALANCE + transferAmount);

        console.log("--- Test Normal User Transfer ---");
        // Transfer between non-blacklisted accounts
        uint256 transferBetweenAmount = 1 ether;
        vm.prank(normalAccount);
        token.transfer(blacklistedAccount, transferBetweenAmount);
        console.log("Non-blacklisted transfer succeeded");
        
        // Verify final balances
        assertEq(
            token.balanceOf(normalAccount), 
            INITIAL_BALANCE + transferAmount - transferBetweenAmount
        );
        assertEq(
            token.balanceOf(blacklistedAccount), 
            INITIAL_BALANCE + transferBetweenAmount
        );
        
        console.log("Vulnerability Exists: Blacklist functionality confirmed (normal transfers unaffected)");
    }
}

contract BlacklistedDummyContract {
    receive() external payable {}
}