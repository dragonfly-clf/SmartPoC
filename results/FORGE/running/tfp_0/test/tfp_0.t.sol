// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract FixedMockFactory {
    constructor() public {}
    
    function createPair(address, address) external payable returns (address) {
        return address(this);
    }
}

contract FixedMockRouter {
    address public immutable factory;
    address public immutable WETH = address(0xE);
    
    constructor(address _factory) public {
        factory = _factory;
    }
    
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint, uint, uint) {
        return (amountTokenDesired, msg.value, 0);
    }
}

contract CoinTokenTest is Test {
    CoinToken public token;
    address owner;
    address alice = address(0xa);
    address bob = address(0xb);
    address carol = address(0xc);
    address service = address(0x1000);
    FixedMockFactory public mockFactory;
    FixedMockRouter public mockRouter;

    function setUp() public {
        owner = address(this);
        vm.deal(owner, 10 ether);
        
        mockFactory = new FixedMockFactory();
        mockRouter = new FixedMockRouter(address(mockFactory));

        // Deploy token with valid service address
        token = new CoinToken{value: 1 ether}(
            "TestToken",
            "TT",
            18,
            1000000,    // supply: 1 million tokens
            1,          // tx fee: 1%
            1,          // lp fee: 1%
            500000,     // MAXAMOUNT: 500k tokens
            10000,      // SELLMAXAMOUNT: 10k tokens
            address(mockRouter),
            owner,
            service
        );

        // Fund test accounts
        token.transfer(alice, 100 * 10**18);
        token.transfer(bob, 100 * 10**18);
    }

    function test_SetMaxTxPercentZeroBlocksNonOwnerTransfers() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialMaxTx = token._maxTxAmount();
        console.log("Initial _maxTxAmount: %s", initialMaxTx);

        console.log("--- Trigger setMaxTxPercent(0) ---");
        token.setMaxTxPercent(0);

        console.log("--- AFTER-Trigger State ---");
        uint256 newMaxTx = token._maxTxAmount();
        console.log("Current _maxTxAmount: %s", newMaxTx);
        console.log("State change: %s -> %s", initialMaxTx, newMaxTx);

        token.transfer(carol, 10);
        assertEq(token.balanceOf(carol), 10);

        vm.expectRevert("Transfer amount exceeds the maxTxAmount.");
        vm.prank(alice);
        token.transfer(carol, 1);
        
        vm.expectRevert("Transfer amount exceeds the maxTxAmount.");
        vm.prank(bob);
        token.transfer(carol, 1);

        if (newMaxTx == 0) {
            console.log("Vulnerability Exists: Non-owner transfers blocked after _maxTxAmount set to 0");
        } else {
            console.log("Vulnerability not Exist: _maxTxAmount unchanged");
        }
    }
}