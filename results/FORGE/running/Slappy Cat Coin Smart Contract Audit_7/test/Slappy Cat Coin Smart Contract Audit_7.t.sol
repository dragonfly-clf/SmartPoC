// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SlappyCat.sol";

// Stateless mock router implementation (top-level contract)
contract MockRouterStateless {
    function factory() external pure returns (address) {
        return address(0x789); // Fixed factory address
    }

    function WETH() external pure returns (address) {
        return address(0x456); // Fixed WETH address
    }
}

// Stateless mock factory implementation (top-level contract)
contract MockFactoryStateless {
    function createPair(address, address) external pure returns (address) {
        return address(0xABC); // Fixed pair address
    }
}

contract SlappyCatVisibilityTest is Test {
    SlappyCat token;
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // BSC mainnet router

    function setUp() public {
        // Set chain ID to BSC mainnet
        uint256 chainId = 56;
        vm.chainId(chainId);

        // Deploy mocks
        MockRouterStateless mockRouter = new MockRouterStateless();
        MockFactoryStateless mockFactory = new MockFactoryStateless();

        // Apply mock implementations to expected addresses
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code); // Override router
        vm.etch(address(0x789), address(mockFactory).code); // Override factory

        // Deploy token contract
        token = new SlappyCat();
    }

    function testExternallyCallableFunctions() public {
        console.log("--- BEFORE-Trigger: Attempt non-state function calls ---");
        console.log("No state changes expected");
        
        console.log("--- Trigger: Call token functions ---");
        bool nameCallable = false;
        bool symbolCallable = false;
        bool decimalsCallable = false;
        
        try token.name() {
            nameCallable = true;
            console.log("name() call successful");
        } catch {
            console.log("name() call reverted");
        }
        
        try token.symbol() {
            symbolCallable = true;
            console.log("symbol() call successful");
        } catch {
            console.log("symbol() call reverted");
        }
        
        try token.decimals() {
            decimalsCallable = true;
            console.log("decimals() call successful");
        } catch {
            console.log("decimals() call reverted");
        }
        
        console.log("--- AFTER-Trigger: No state change to snapshot ---");
        console.log("Visibility verification complete");
        
        if (nameCallable && symbolCallable && decimalsCallable) {
            console.log("Vulnerability Exists: All token visibility functions called successfully");
        } else {
            console.log("Vulnerability not Exist: At least one token function not callable");
        }
    }
}