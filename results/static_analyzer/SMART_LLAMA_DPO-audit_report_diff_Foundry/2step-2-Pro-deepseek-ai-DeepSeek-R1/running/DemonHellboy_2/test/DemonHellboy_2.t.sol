// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DemonHellboy.sol";

contract MockUniswapV2Router {
    address public factory;
    address public WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0xAbcDE);
    }
}

contract MockWETH {
    function deposit() public payable {}
    function transfer(address, uint256) public pure returns (bool) { return true; }
}

contract TestAddressFeeUniqueness is Test {
    DemonHellboy token;
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address owner;
    
    address sender = makeAddr("sender");
    address recipient = makeAddr("recipient");
    address feeAddress = makeAddr("feeAddress");
    uint256 constant INITIAL_BALANCE = 1000 ether;
    uint256 constant TRANSFER_AMOUNT = 100 ether;

    function setUp() public {
        owner = makeAddr("owner");
        
        // Deploy mock Uniswap infrastructure
        MockWETH weth = new MockWETH();
        MockUniswapV2Factory factory = new MockUniswapV2Factory();
        
        // Create router contract
        MockUniswapV2Router router = new MockUniswapV2Router(address(factory), address(weth));
        
        // Overwrite router address with mock implementation
        vm.etch(ROUTER_ADDRESS, address(router).code);
        vm.store(
            ROUTER_ADDRESS, 
            bytes32(uint256(0)), 
            bytes32(uint256(uint160(address(factory))))
        );
        vm.store(
            ROUTER_ADDRESS, 
            bytes32(uint256(1)), 
            bytes32(uint256(uint160(address(weth))))
        );

        // Deploy token with working Uniswap mocks
        token = new DemonHellboy();
        token.transferOwnership(owner);

        // Transfer initial tokens
        token.transfer(sender, INITIAL_BALANCE);
        token.transfer(feeAddress, INITIAL_BALANCE);
    }

    function _simulateTransferAndGetFee(address from, address to, uint256 amount) internal returns (uint256) {
        uint256 balanceBeforeFrom = token.balanceOf(from);
        uint256 balanceBeforeTo = token.balanceOf(to);
        
        vm.prank(from);
        token.transfer(to, amount);
        
        uint256 balanceAfterTo = token.balanceOf(to);
        uint256 actualToIncrease = balanceAfterTo - balanceBeforeTo;
        uint256 actualFee = amount - actualToIncrease;
        return actualFee;
    }

    function testBuyFeeDuplicateSettings() public {
        console.log("--- BEFORE: Initial Transfer without Fee ---");
        uint256 initialFee = _simulateTransferAndGetFee(sender, feeAddress, TRANSFER_AMOUNT);
        console.log("Initial fee deducted: ", initialFee);

        console.log("--- ACTION: Set Buy Fee (first time) ---");
        vm.prank(owner);
        token.setBuyAddressFee(feeAddress, true, 1, 2);

        console.log("--- AFTER: Transfer after Fee Set ---");
        uint256 feeAfterFirstSetting = _simulateTransferAndGetFee(sender, feeAddress, TRANSFER_AMOUNT);
        console.log("Fee after first setting: ", feeAfterFirstSetting);

        console.log("--- ACTION: Set Duplicate Buy Fee ---");
        vm.prank(owner);
        token.setBuyAddressFee(feeAddress, false, 3, 4);

        console.log("--- AFTER: Transfer after Duplicate Setting ---");
        uint256 feeAfterDuplicate = _simulateTransferAndGetFee(sender, feeAddress, TRANSFER_AMOUNT);
        console.log("Fee after duplicate setting: ", feeAfterDuplicate);

        console.log("--- FEE COMPARISON ---");
        bool vulnerabilityExists = (feeAfterFirstSetting == feeAfterDuplicate);
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Buy fee remains unchanged after duplicate settings");
        } else {
            console.log("Vulnerability not Exist: Buy fee changed after duplicate settings");
        }
    }

    function testSellFeeDuplicateSettings() public {
        console.log("--- BEFORE: Initial Transfer without Fee ---");
        uint256 initialFee = _simulateTransferAndGetFee(feeAddress, recipient, TRANSFER_AMOUNT);
        console.log("Initial fee deducted: ", initialFee);

        console.log("--- ACTION: Set Sell Fee (first time) ---");
        vm.prank(owner);
        token.setSellAddressFee(feeAddress, true, 1, 2);

        console.log("--- AFTER: Transfer after Fee Set ---");
        uint256 feeAfterFirstSetting = _simulateTransferAndGetFee(feeAddress, recipient, TRANSFER_AMOUNT);
        console.log("Fee after first setting: ", feeAfterFirstSetting);

        console.log("--- ACTION: Set Duplicate Sell Fee ---");
        vm.prank(owner);
        token.setSellAddressFee(feeAddress, false, 3, 4);

        console.log("--- AFTER: Transfer after Duplicate Setting ---");
        uint256 feeAfterDuplicate = _simulateTransferAndGetFee(feeAddress, recipient, TRANSFER_AMOUNT);
        console.log("Fee after duplicate setting: ", feeAfterDuplicate);

        console.log("--- FEE COMPARISON ---");
        bool vulnerabilityExists = (feeAfterFirstSetting == feeAfterDuplicate);
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Sell fee remains unchanged after duplicate settings");
        } else {
            console.log("Vulnerability not Exist: Sell fee changed after duplicate settings");
        }
    }
}