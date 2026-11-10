// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DigitalattoCoin.sol";

contract MockBUSD {
    function balanceOf(address) external pure returns (uint256) { return 0; }
    function transfer(address, uint256) external pure returns (bool) { return true; }
    function approve(address, uint256) external pure returns (bool) { return true; }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

contract MockDexRouter {
    MockFactory public immutable factory;
    MockBUSD public BUSD;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    
    constructor() {
        factory = new MockFactory();
        BUSD = new MockBUSD();
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256,
        address[] calldata,
        address,
        uint256
    ) external payable {}

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256,
        uint256,
        address[] calldata,
        address,
        uint256
    ) external {}

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
}

contract ZeroDivisionTest is Test {
    DigitalattoCoin token;
    MockDexRouter router;
    address owner = address(this);
    address alice = address(0x1);
    address bob = address(0x2);
    uint256 constant TOKEN_AMOUNT = 10**18; // 1 token with decimals

    function setUp() public {
        router = new MockDexRouter();
        token = new DigitalattoCoin(address(router));
        
        // Set sufficient tx limit and fund contract
        token.setTxLimit(TOKEN_AMOUNT * 10); // 10 token limit
        token.setSwapBackSettings(false, TOKEN_AMOUNT);
        
        // Transfer tokens to contract and Alice
        token.transfer(address(token), TOKEN_AMOUNT);
        token.transfer(alice, TOKEN_AMOUNT * 2); // Double amount for safety
    }
    
    function test_ZeroDivisionWhenFeesZero() public {
        // Enable swap back with zero fees (trigger division issue)
        token.setSwapBackSettings(true, TOKEN_AMOUNT);
        token.setFees(0, 0, 0, 0, 100); // Set fees to zero
        
        // Provide ETH for swapping operations
        vm.deal(address(token), 1 ether);
        
        // Test should revert with division error
        console.log("--- Triggering Transfer ---");
        bool vulnerabilityExists = false;
        
        try this.attemptTransfer() returns (bool) {
            // If no revert: vulnerability doesn't exist
        } catch (bytes memory reason) {
            // Compare error hashes
            if (keccak256(reason) == keccak256(stdError.divisionError)) {
                vulnerabilityExists = true;
            }
        }
        
        // Print final vulnerability status
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Transfer reverts with division error when fees are zero");
        } else {
            console.log("Vulnerability not Exist: No division error during transfer");
        }
    }
    
    function attemptTransfer() external returns (bool) {
        vm.prank(alice);
        token.transfer(bob, TOKEN_AMOUNT);
        return true;
    }
}