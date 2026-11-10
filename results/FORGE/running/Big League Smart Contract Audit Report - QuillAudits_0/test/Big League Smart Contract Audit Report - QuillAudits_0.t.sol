// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/StandardToken.sol";

contract MockWBNB {
    fallback() external payable {}
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123456);
    }
}

contract MockRouter {
    address public factory;
    
    constructor(address _factory) {
        factory = _factory;
    }
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256, uint256, address[] calldata, address, uint256
    ) external {}
    
    function addLiquidityETH(
        address, uint256, uint256, uint256, address, uint256
    ) external payable returns (uint256, uint256, uint256) {
        return (0, 0, 0);
    }
}

contract TransferFromBackdoorTest is Test {
    StandardToken token;
    address owner = vm.addr(1);
    address holder = vm.addr(2);
    address spender = vm.addr(3);
    
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    uint256 constant MAX_ALLOWANCE = type(uint256).max;
    uint256 constant INITIAL_HOLDER_BALANCE = 100 ether;
    uint256 constant TRANSFER_AMOUNT = 10 ether;

    function setUp() public {
        // Deploy and setup mock WBNB
        MockWBNB mockWBNB = new MockWBNB();
        vm.etch(WBNB, address(mockWBNB).code);
        
        // Deploy and setup mock factory
        MockFactory mockFactory = new MockFactory();
        
        // Deploy mock router (delegates to factory)
        MockRouter mockRouter = new MockRouter(address(mockFactory));
        vm.etch(PANCAKE_ROUTER, address(mockRouter).code);
        
        // Set factory address in router's storage (slot 0)
        vm.store(PANCAKE_ROUTER, bytes32(0), bytes32(uint256(uint160(address(mockFactory)))));
        
        // Deploy the token contract
        vm.startPrank(owner);
        token = new StandardToken(owner);
        
        // Initial token distribution
        token.mint(owner, 1000 ether);
        token.transfer(holder, INITIAL_HOLDER_BALANCE);
        vm.stopPrank();
        
        // Holder approves spender with max allowance
        vm.prank(holder);
        token.approve(spender, MAX_ALLOWANCE);
    }

    function testAllowanceNotDecreased() public {
        console.log("--- BEFORE-Trigger Transfer ---");
        // Capture pre-transfer state
        uint256 initialAllowance = token.allowance(holder, spender);
        uint256 initialHolderBalance = token.balanceOf(holder);
        uint256 initialSpenderBalance = token.balanceOf(spender);
        
        console.log("Initial Allowance:", initialAllowance);
        console.log("Initial Holder Balance:", initialHolderBalance);
        console.log("Initial Spender Balance:", initialSpenderBalance);
        
        console.log("--- Trigger TransferFrom ---");
        // Execute critical operation
        vm.prank(spender);
        token.transferFrom(holder, spender, TRANSFER_AMOUNT);
        
        console.log("--- AFTER-Trigger Transfer ---");
        // Capture post-transfer state
        uint256 newAllowance = token.allowance(holder, spender);
        uint256 newHolderBalance = token.balanceOf(holder);
        uint256 newSpenderBalance = token.balanceOf(spender);
        
        console.log("Allowance After:", newAllowance);
        console.log("Holder Balance After:", newHolderBalance);
        console.log("Spender Balance After:", newSpenderBalance);
        
        // Calculate balance changes
        uint256 holderBalanceDiff = initialHolderBalance - newHolderBalance;
        uint256 spenderBalanceDiff = newSpenderBalance - initialSpenderBalance;
        
        console.log("Holder Balance Difference:", holderBalanceDiff);
        console.log("Spender Balance Difference:", spenderBalanceDiff);
        
        // Final vulnerability verdict
        if (newAllowance == MAX_ALLOWANCE) {
            console.log("Vulnerability Exists: Allowance remains max after transfer");
        } else {
            console.log("Vulnerability not Exist: Allowance decreased correctly");
        }
    }
}