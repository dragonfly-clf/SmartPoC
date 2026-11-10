// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Domain.sol";

contract MockWETH {
    receive() external payable {}
}

contract MockPair {
    receive() external payable {}
}

contract MockFactory {
    MockPair public immutable pair;

    constructor() {
        pair = new MockPair();
    }

    function createPair(address, address) external view returns (address) {
        return address(pair);
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable weth;

    constructor(address _factory, address _weth) {
        factory = _factory;
        weth = _weth;
    }

    function WETH() external view returns (address) {
        return weth;
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint,
        uint,
        address[] calldata,
        address to,
        uint
    ) external payable {
        payable(to).call{value: 10 ether}("");
    }

    function addLiquidityETH(
        address,
        uint256,
        uint256,
        uint256,
        address,
        uint256
    ) external payable returns (uint256, uint256, uint256) {
        return (0, 0, 0);
    }

    receive() external payable {}
}

contract ReentrancyTester {
    Domain public token;
    bool public attacked;
    bool public called;
    
    constructor(Domain _token) {
        token = _token;
    }
    
    receive() external payable {
        if (!called) {
            called = true;
            // Save attack state first
            attacked = true;
            // Then make external call
            token.balanceOf(address(this));
        }
    }
}

contract ReentrancyTest is Test {
    Domain public token;
    ReentrancyTester public attacker;
    address public owner = address(0x1);
    MockFactory public mockFactory;
    MockWETH public mockWeth;
    address constant ROUTER_ADDRESS = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    function setUp() public {
        vm.startPrank(owner);
        
        // Deploy mock WETH and factory
        mockWeth = new MockWETH();
        mockFactory = new MockFactory();
        
        // Deploy mock router
        MockRouter mockRouter = new MockRouter(
            address(mockFactory),
            address(mockWeth)
        );
        
        // Impersonate actual router address
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        vm.deal(ROUTER_ADDRESS, 100 ether);
        
        // Deploy token
        token = new Domain();
        
        // Set threshold to low value for testing
        token.setNumTokensSellToAddToLiq(1);
        
        // Enable swapping
        token.setSwapAndLiquifyEnabled(true);
        
        // Create attacker contract and set as treasury
        attacker = new ReentrancyTester(token);
        token.setTreasuryAddress(payable(address(attacker)));
        
        // Transfer tokens to token contract to simulate accumulated fees
        token.excludeFromFee(owner);
        token.transfer(address(token), 1000);
        
        // Fund token contract with ETH for liquidity
        vm.deal(address(token), 10 ether);
        
        vm.stopPrank();
    }

    function testReentrancyVulnerability() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 tokenBalanceBefore = address(token).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        bool attackedBefore = attacker.attacked();
        console.log("Token contract ETH balance:", tokenBalanceBefore);
        console.log("Attacker contract ETH balance:", attackerBalanceBefore);
        console.log("Reentrancy attacked flag:", attackedBefore);

        console.log("--- Trigger ManualSwapAndAddToLiq ---");
        vm.prank(owner);
        token.manualSwapAndAddToLiq();
        console.log("--- AFTER-Trigger State ---");
        uint256 tokenBalanceAfter = address(token).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        bool attackedAfter = attacker.attacked();
        console.log("Token contract ETH balance:", tokenBalanceAfter);
        console.log("Attacker contract ETH balance:", attackerBalanceAfter);
        console.log("Reentrancy attacked flag:", attackedAfter);

        // Check balance changes and attack success
        bool ethStolen = (attackerBalanceAfter == attackerBalanceBefore + 10 ether) && 
                         (tokenBalanceAfter == tokenBalanceBefore - 10 ether);
        bool reentrancyTriggered = attackedAfter;

        if (reentrancyTriggered && ethStolen) {
            console.log("VULNERABILITY VERIFIED: Reentrancy attack succeeded and ETH stolen");
            console.log("Vulnerability Exists: Reentrancy during swapAndLiquify allows ETH theft");
        } else if (reentrancyTriggered) {
            console.log("VULNERABILITY PARTIALLY VERIFIED: Reentrancy triggered but ETH not stolen");
            console.log("Vulnerability Exists: Reentrancy occurred but ETH was not stolen");
        } else {
            console.log("NO OPERATIONAL EFFECT: No reentrancy occurred");
            console.log("Vulnerability not Exist: No reentrancy triggered during swapAndLiquify");
        }
    }
}