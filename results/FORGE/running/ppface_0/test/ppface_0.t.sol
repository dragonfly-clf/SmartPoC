// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Token.sol";

contract MockRouter {
    address public factory;
    address public immutable WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0xdead);
    }
}

contract MockWETH {
    function deposit() external payable {}
    function transfer(address, uint) external pure returns (bool) { return true; }
    function withdraw(uint) external {}
}

contract TokenTradeTest is Test {
    Token token;
    address owner = address(0x1);
    address alice = address(0x2);
    address bob = address(0x3);
    address routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    function setUp() public {
        // Set chain ID to Ethereum (1)
        vm.chainId(1);
        
        // Deploy mocks and setup router
        MockWETH weth = new MockWETH();
        MockFactory factory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(factory), address(weth));
        
        // Replace the router address with our mock
        vm.etch(routerAddress, address(mockRouter).code);
        vm.store(routerAddress, bytes32(uint256(0)), bytes32(uint256(uint160(address(factory)))));
        vm.store(routerAddress, bytes32(uint256(1)), bytes32(uint256(uint160(address(weth)))));
        
        // Deploy token contract
        vm.startPrank(owner);
        token = new Token();
        
        // Distribute initial tokens
        uint256 decimals = token.decimals();
        uint256 amount = 1000 * 10 ** decimals;
        token.transfer(alice, amount);
        vm.stopPrank();
    }

    function testTransferFailsWhenTradingDisabled() public {
        // Prepare transfer
        uint256 transferAmount = 100 * 10 ** token.decimals();
        
        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 bobBalanceBefore = token.balanceOf(bob);
        console.log("Alice balance before transfer: %s", aliceBalanceBefore);
        console.log("Bob balance before transfer: %s", bobBalanceBefore);
        
        console.log("--- Trigger Transfer (should revert) ---");
        vm.startPrank(alice);
        bool transferSuccess = true;
        try token.transfer(bob, transferAmount) {
            // Transfer should not succeed
            transferSuccess = true;
        } catch Error(string memory reason) {
            // Verify revert reason
            bytes32 actualReason = keccak256(abi.encodePacked(reason));
            bytes32 expectedReason = keccak256(abi.encodePacked("Trading is not enabled"));
            transferSuccess = actualReason != expectedReason;
            console.log("Revert caught: %s", reason);
        } catch {
            // Catch other revert types
            transferSuccess = true;
            console.log("Unexpected revert");
        }
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger Transfer ---");
        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 bobBalanceAfter = token.balanceOf(bob);
        console.log("Alice balance after transfer: %s", aliceBalanceAfter);
        console.log("Bob balance after transfer: %s", bobBalanceAfter);

        // Determine vulnerability state
        bool balancesChanged = (aliceBalanceBefore != aliceBalanceAfter) || 
                               (bobBalanceBefore != bobBalanceAfter);
        
        console.log("--- DIFFERENTIAL COMPARISON ---");
        console.log("Balances unchanged? %s", !balancesChanged ? "PASS" : "FAIL");
        console.log("Transfer succeeded unexpectedly? %s", transferSuccess ? "FAIL" : "PASS");
        
        // Final vulnerability verdict
        if (balancesChanged || transferSuccess) {
            console.log("Vulnerability Exists: Transfer completed and/or balances changed when trading is disabled");
        } else {
            console.log("Vulnerability not Exist: Transfer failed and balances unchanged as expected");
        }
    }

    function testTradingEnabledByOwner() public {
        // Enable trading
        vm.prank(owner);
        token.enableTrading();

        // Perform transfer
        uint256 transferAmount = 100 * 10 ** token.decimals();
        vm.prank(alice);
        token.transfer(bob, transferAmount);

        // Verify balances
        uint256 aliceExpected = 900 * 10 ** token.decimals();
        uint256 bobExpected = transferAmount;
        assertEq(token.balanceOf(alice), aliceExpected, "Alice balance incorrect");
        assertEq(token.balanceOf(bob), bobExpected, "Bob balance incorrect");
    }

    function testCannotDisableTradingAfterEnabling() public {
        // Enable trading
        vm.prank(owner);
        token.enableTrading();

        // Perform transfers
        uint256 firstTransfer = 100 * 10 ** token.decimals();
        vm.prank(alice);
        token.transfer(bob, firstTransfer);

        uint256 secondTransfer = 50 * 10 ** token.decimals();
        vm.prank(alice);
        token.transfer(bob, secondTransfer);

        // Verify final balances
        uint256 totalTransferred = firstTransfer + secondTransfer;
        uint256 aliceExpected = 1000 * 10 ** token.decimals() - totalTransferred;
        assertEq(token.balanceOf(alice), aliceExpected, "Alice final balance incorrect");
        assertEq(token.balanceOf(bob), totalTransferred, "Bob final balance incorrect");
    }
}