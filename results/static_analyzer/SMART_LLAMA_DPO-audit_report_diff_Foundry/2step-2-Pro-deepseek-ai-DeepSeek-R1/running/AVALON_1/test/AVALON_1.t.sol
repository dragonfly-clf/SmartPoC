// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/AVALON.sol";

contract AVALONTest is Test {
    AVALON token;
    address constant server = 0x3427d4b12875D5f459b25B993FfbaE2243571ca8;
    address user = makeAddr("user");
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address factoryAddress;
    address pairAddress;
    address burnWallet = makeAddr("burnWallet");
    
    uint256 constant TOKEN_DECIMALS = 18;
    uint256 constant TOKEN = 10 ** TOKEN_DECIMALS;
    bytes4 private constant FACTORY_SIG = bytes4(keccak256("factory()"));
    bytes4 private constant WETH_SIG = bytes4(keccak256("WETH()"));

    function setUp() public {
        // Setup mock Uniswap router
        factoryAddress = makeAddr("factory");
        pairAddress = makeAddr("pair");
        
        // Mock router responses
        vm.etch(routerAddress, new bytes(0x42));
        vm.mockCall(
            routerAddress, 
            abi.encodeWithSelector(FACTORY_SIG), 
            abi.encode(factoryAddress)
        );
        vm.mockCall(
            routerAddress, 
            abi.encodeWithSelector(WETH_SIG), 
            abi.encode(makeAddr("weth"))
        );
        
        // Mock factory createPair response
        vm.mockCall(
            factoryAddress, 
            abi.encodeWithSelector(bytes4(keccak256("createPair(address,address)"))),
            abi.encode(pairAddress)
        );

        // Deploy token
        token = new AVALON(burnWallet);
        
        // Configure test environment
        vm.prank(token.owner());
        token.excludeFromFee(server);
        
        vm.prank(token.owner());
        token.excludeFromFee(user);
        
        vm.prank(token.owner());
        token.setTaxFeePercent(0);
        
        vm.prank(token.owner());
        token.setLiquidityFeePercent(0);
    }

    function testWithdrawFailsWhenServerBalanceInsufficient() public {
        // Set initial balances
        uint256 initialBalance = 50 ether;
        token.transfer(server, initialBalance);
        
        uint32 initialCount = token.WithdrawCount(user);
        uint256 withdrawAmount = 100 ether;

        console.log("--- BEFORE-Trigger Withdrawal ---");
        uint256 serverBefore = token.balanceOf(server);
        uint256 userBefore = token.balanceOf(user);
        uint32 countBefore = token.WithdrawCount(user);
        console.log("Server balance: %s", serverBefore);
        console.log("User balance: %s", userBefore);
        console.log("Withdraw count: %s", uint256(countBefore));

        console.log("--- Trigger Withdrawal ---");
        // Attempt withdrawal (should fail)
        vm.prank(server);
        vm.expectRevert();
        token.Withdraw(user, int256(withdrawAmount), initialCount);

        console.log("--- AFTER-Trigger Withdrawal ---");
        uint256 serverAfter = token.balanceOf(server);
        uint256 userAfter = token.balanceOf(user);
        uint32 countAfter = token.WithdrawCount(user);
        console.log("Server balance: %s", serverAfter);
        console.log("User balance: %s", userAfter);
        console.log("Withdraw count: %s", uint256(countAfter));

        // Differential check - state should remain unchanged
        bool stateChanged = (serverBefore != serverAfter) || 
            (userBefore != userAfter) || 
            (countBefore != countAfter);
        
        if (stateChanged) {
            console.log("Vulnerability Exists: State changed despite insufficient server balance");
        } else {
            console.log("Vulnerability not Exist: State unchanged after expected withdrawal failure");
        }
    }

    function testWithdrawSuccessWhenServerHasSufficientBalance() public {
        // Set initial balances
        uint256 withdrawAmount = 100 ether;
        token.transfer(server, withdrawAmount);
        
        uint32 initialCount = token.WithdrawCount(user);

        console.log("--- BEFORE-Trigger Withdrawal ---");
        uint256 serverBefore = token.balanceOf(server);
        uint256 userBefore = token.balanceOf(user);
        uint32 countBefore = token.WithdrawCount(user);
        console.log("Server balance: %s", serverBefore);
        console.log("User balance: %s", userBefore);
        console.log("Withdraw count: %s", uint256(countBefore));

        console.log("--- Trigger Withdrawal ---");
        // Successful withdrawal
        vm.prank(server);
        bool success = token.Withdraw(user, int256(withdrawAmount), initialCount);
        assertTrue(success, "Withdrawal should succeed");

        console.log("--- AFTER-Trigger Withdrawal ---");
        uint256 serverAfter = token.balanceOf(server);
        uint256 userAfter = token.balanceOf(user);
        uint32 countAfter = token.WithdrawCount(user);
        console.log("Server balance: %s", serverAfter);
        console.log("User balance: %s", userAfter);
        console.log("Withdraw count: %s", uint256(countAfter));

        // Check expected state changes
        bool stateChangedCorrectly = 
            (serverAfter == serverBefore - withdrawAmount) && 
            (userAfter == userBefore + withdrawAmount) && 
            (countAfter == countBefore + 1);
        
        if (stateChangedCorrectly) {
            console.log("Vulnerability not Exist: Withdrawal succeeded and state updated correctly");
        } else {
            console.log("Vulnerability Exists: Incorrect state after withdrawal, potential logic error");
        }
    }
}