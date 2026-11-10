// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BetSwampERC20Token.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0xC0FFEE);
    }
}

contract MockUniswapV2Router {
    function factory() external pure returns (address) {
        return address(0x123456);
    }
    
    function WETH() external pure returns (address) {
        return address(0xdeadbeef);
    }
}

contract BetSwampERC20TokenTest is Test {
    BetSwampERC20Token token;
    address owner = address(0x1234);
    address user = address(0x5678);
    uint256 constant TOTAL_SUPPLY = 114 * 1e4 * 1e9; // 1.14 million tokens with 9 decimals
    
    // Helper to get runtime bytecode (for Solidity 0.7.5 compatibility)
    function _getCode(address addr) internal view returns (bytes memory o_code) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        o_code = new bytes(size);
        if (size > 0) {
            assembly {
                extcodecopy(addr, add(o_code, 0x20), 0, size)
            }
        }
    }

    function setUp() public {
        // Create mock implementations
        MockUniswapV2Factory mockFactory = new MockUniswapV2Factory();
        MockUniswapV2Router mockRouter = new MockUniswapV2Router();
        
        // Fix known router address (PancakeSwap)
        address pancakeswapRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        
        // Etch mock code onto fixed addresses
        vm.etch(address(0x123456), _getCode(address(mockFactory)));
        vm.etch(pancakeswapRouter, _getCode(address(mockRouter)));
        
        // Deploy token
        vm.startPrank(owner);
        token = new BetSwampERC20Token();
        vm.stopPrank();
    }

    function test_CannotSetMaxWalletBelowMin() public {
        emit log("--- BEFORE-Trigger MaxWallet ---");
        uint256 state_before = token.maxWallet();
        emit log_named_uint("Starting maxWallet", state_before);
        
        uint256 totalSupply = token.totalSupply();
        uint256 minAllowed = totalSupply / 100; // 1% min
        uint256 invalidValue = minAllowed - 1;

        emit log("--- Trigger setMaxWalletAmount(invalid) ---");
        vm.prank(owner);
        vm.expectRevert("Can't set max wallet below 1% of total supply!");
        token.setMaxWalletAmount(invalidValue);

        emit log("--- AFTER-Trigger MaxWallet ---");
        uint256 state_after = token.maxWallet();
        emit log_named_uint("maxWallet after", state_after);
        
        bool stateChanged = state_before != state_after;
        if (stateChanged) {
            emit log("Vulnerability Exists: Validation bypassed!");
        } else {
            emit log("Vulnerability not Exist: Validation works");
        }
        
        if (stateChanged) {
            emit log("Vulnerability Exists: Can set maxWallet below min");
        } else {
            emit log("Vulnerability not Exist: Max wallet constraints enforced");
        }
    }

    function test_SetsValidMaxWallet() public {
        emit log("--- BEFORE-Trigger MaxWallet ---");
        uint256 state_before = token.maxWallet();
        emit log_named_uint("Starting maxWallet", state_before);
        
        uint256 totalSupply = token.totalSupply();
        uint256 validValue = totalSupply / 50; // 2% of supply
        
        emit log("--- Trigger setMaxWalletAmount(valid) ---");
        vm.prank(owner);
        token.setMaxWalletAmount(validValue);
        
        emit log("--- AFTER-Trigger MaxWallet ---");
        uint256 state_after = token.maxWallet();
        emit log_named_uint("New maxWallet", state_after);
        
        assertEq(state_after, validValue, "Max wallet should be updated");
        emit log("Vulnerability not Exist: Valid value setting accepted");
    }

    function test_NonOwnerCannotSetMaxWallet() public {
        emit log("--- BEFORE-Trigger MaxWallet ---");
        uint256 state_before = token.maxWallet();
        emit log_named_uint("Starting maxWallet", state_before);
        
        emit log("--- Trigger setMaxWalletAmount(non-owner) ---");
        vm.prank(user);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setMaxWalletAmount(100000);
        
        emit log("--- AFTER-Trigger MaxWallet ---");
        uint256 state_after = token.maxWallet();
        emit log_named_uint("maxWallet after", state_after);

        bool stateChanged = state_before != state_after;
        if (stateChanged) {
            emit log("ALERT: State changed despite revert!");
        } else {
            emit log("State stable: Access control enforced");
        }
        
        if (stateChanged) {
            emit log("Vulnerability Exists: Non-owner modified state");
        } else {
            emit log("Vulnerability not Exist: Access control intact");
        }
    }

    function test_CannotSetMaxTxBelowMin() public {
        emit log("--- BEFORE-Trigger MaxTx ---");
        uint256 state_before = token.maxTransactionAmount();
        emit log_named_uint("Starting maxTx", state_before);
        
        uint256 totalSupply = token.totalSupply();
        uint256 minAllowed = totalSupply / 100; // 1% min
        uint256 invalidValue = minAllowed - 1;

        emit log("--- Trigger setMaxTransactionAmount(invalid) ---");
        vm.prank(owner);
        vm.expectRevert("Can't set max transaction below 1% of total supply!");
        token.setMaxTransactionAmount(invalidValue);

        emit log("--- AFTER-Trigger MaxTx ---");
        uint256 state_after = token.maxTransactionAmount();
        emit log_named_uint("maxTx after", state_after);
        
        bool stateChanged = state_before != state_after;
        if (stateChanged) {
            emit log("Vulnerability Exists: Validation bypassed!");
        } else {
            emit log("Vulnerability not Exist: Validation works");
        }
        
        if (stateChanged) {
            emit log("Vulnerability Exists: Can set maxTx below min");
        } else {
            emit log("Vulnerability not Exist: Max tx constraints enforced");
        }
    }

    function test_SetsValidMaxTx() public {
        emit log("--- BEFORE-Trigger MaxTx ---");
        uint256 state_before = token.maxTransactionAmount();
        emit log_named_uint("Starting maxTx", state_before);
        
        uint256 totalSupply = token.totalSupply();
        uint256 validValue = totalSupply / 50; // 2% of supply
        
        emit log("--- Trigger setMaxTransactionAmount(valid) ---");
        vm.prank(owner);
        token.setMaxTransactionAmount(validValue);
        
        emit log("--- AFTER-Trigger MaxTx ---");
        uint256 state_after = token.maxTransactionAmount();
        emit log_named_uint("New maxTx", state_after);
        
        assertEq(state_after, validValue, "Max transaction should be updated");
        emit log("Vulnerability not Exist: Valid value setting accepted");
    }

    function test_ValuesPersistAfterTokenTransfer() public {
        uint256 totalSupply = token.totalSupply();
        uint256 newMaxWallet = (totalSupply * 2) / 100; // 2% of supply
        uint256 newMaxTx = (totalSupply * 3) / 100; // 3% of supply
        
        emit log("--- BEFORE-Trigger SetValues ---");
        uint256 maxWalletBefore = token.maxWallet();
        uint256 maxTxBefore = token.maxTransactionAmount();
        emit log_named_uint("maxWallet before", maxWalletBefore);
        emit log_named_uint("maxTx before", maxTxBefore);
        
        // Set new values
        vm.prank(owner);
        token.setMaxWalletAmount(newMaxWallet);
        
        vm.prank(owner);
        token.setMaxTransactionAmount(newMaxTx);
        
        emit log("--- AFTER-Trigger SetValues ---");
        uint256 maxWalletAfterSet = token.maxWallet();
        uint256 maxTxAfterSet = token.maxTransactionAmount();
        emit log_named_uint("maxWallet after set", maxWalletAfterSet);
        emit log_named_uint("maxTx after set", maxTxAfterSet);
        
        // Verify consistency after token transfer
        emit log("--- Trigger TokenTransfer ---");
        vm.prank(owner);
        token.transfer(user, 1000);
        
        emit log("--- AFTER-Trigger TokenTransfer ---");
        uint256 maxWalletFinal = token.maxWallet();
        uint256 maxTxFinal = token.maxTransactionAmount();
        emit log_named_uint("maxWallet final", maxWalletFinal);
        emit log_named_uint("maxTx final", maxTxFinal);

        // Assert persistance
        assertEq(maxWalletFinal, newMaxWallet, "Max wallet should persist");
        assertEq(maxTxFinal, newMaxTx, "Max transaction should persist");
        emit log("Vulnerability not Exist: Values persist after transfer");
    }
}