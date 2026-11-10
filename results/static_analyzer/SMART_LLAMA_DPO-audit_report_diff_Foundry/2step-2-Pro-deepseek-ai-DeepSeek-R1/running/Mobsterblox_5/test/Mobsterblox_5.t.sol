// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Mobsterblox.sol";

contract MockRevertingRouter {
    bool public constant isMock = true; // Avoid function clash with Mobsterblox
    address public factory;
    address public immutable WETH;
    
    constructor() {
        factory = address(this);
        WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
    
    // Minimal factory implementation for pair creation
    function createPair(address, address) external pure returns (address pair) {
        return address(0x123); // Dummy pair address
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint, /* amountIn */
        uint, /* amountOutMin */
        address[] calldata, /* path */
        address to,
        uint /* deadline */
    ) external {
        // Simulate successful swap
        payable(to).transfer(1 ether);
    }
    
    function addLiquidityETH(
        address, /* token */
        uint, /* amountTokenDesired */
        uint, /* amountTokenMin */
        uint, /* amountETHMin */
        address, /* to */
        uint /* deadline */
    ) external payable returns (uint, uint, uint) {
        // Force revert during liquidity addition
        revert("AddLiquidityReverted");
    }
    
    receive() external payable {}
}

contract MobsterbloxAtomicityTest is Test {
    Mobsterblox token;
    MockRevertingRouter mockRouter;
    address owner = address(0x1);
    address user1 = address(0x2);
    uint256 constant TOTAL_SUPPLY = 1_000_000 * 10**18;

    function setUp() public {
        vm.startPrank(owner);
        // Fund mock router with ETH for swap simulation
        mockRouter = new MockRevertingRouter();
        vm.deal(address(mockRouter), 10 ether);

        // Deploy token with mock router
        token = new Mobsterblox(
            "TestToken",
            "TT",
            18,
            TOTAL_SUPPLY / 10**18,
            1,   // txFee
            1,   // lpFee
            1,   // devFee
            address(mockRouter), // router address
            address(this),       // fee address
            owner,               // token owner
            address(0)           // service address
        );
        
        // Configure token liquidity settings
        token.setSwapAndLiquifyEnabled(true);
        token.setNumTokensSellToAddToLiquidity(1 ether);
        
        // Seed token contract with initial balance
        token.transfer(address(token), 10_000 ether);
        vm.stopPrank();
    }

    function testSwapRevertKeepsAtomicity() public {
        // ---- BEFORE state capture ----
        uint256 initialTokenBalance = token.balanceOf(address(token));
        uint256 initialEthBalance = address(token).balance;
        console.log("--- BEFORE-Trigger ---");
        console.log("Token contract token balance: %s", initialTokenBalance);
        console.log("Token contract ETH balance:   %s", initialEthBalance);
        
        // Ensure contract has sufficient tokens to trigger swap
        assertGe(initialTokenBalance, 1 ether, "Insufficient tokens for swap");
        
        // ---- Trigger vulnerability ----
        console.log("--- Trigger ---");
        console.log("Executing transfer (expect revert)");
        vm.prank(owner);
        vm.expectRevert("AddLiquidityReverted");
        token.transfer(user1, 1 ether);

        // ---- AFTER state capture ----
        uint256 newTokenBalance = token.balanceOf(address(token));
        uint256 newEthBalance = address(token).balance;
        console.log("--- AFTER-Trigger ---");
        console.log("Token contract token balance: %s", newTokenBalance);
        console.log("Token contract ETH balance:   %s", newEthBalance);
        
        // ---- State validation ----
        bool tokenChanged = initialTokenBalance != newTokenBalance;
        bool ethChanged = initialEthBalance != newEthBalance;
        bool vulnerabilityExists = tokenChanged || ethChanged;
        
        // Final verdict
        if (vulnerabilityExists) {
            console.log("VULNERABILITY EXISTS: State changed during liquidity-add revert");
        } else {
            console.log("Vulnerability not Exist: State maintained atomicity during revert");
        }
    }
}