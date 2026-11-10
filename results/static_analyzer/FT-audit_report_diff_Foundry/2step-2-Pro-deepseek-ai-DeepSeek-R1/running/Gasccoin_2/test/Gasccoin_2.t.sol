// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Gasccoin.sol";

contract GasccoinGasDosTest is Test {
    Gasccoin public token;
    address public owner = address(0x1);
    
    // Mock contracts
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WETH_ADDRESS = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address constant MOCK_FACTORY = address(0x1234);
    address constant MOCK_PAIR = address(0x5678);

    function setUp() public {
        vm.startPrank(owner);
        
        // Mock router responses
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("factory()"),
            abi.encode(MOCK_FACTORY)
        );
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("WETH()"),
            abi.encode(WETH_ADDRESS)
        );
        
        // Mock factory createPair response (for any addresses)
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSelector(bytes4(0xc9c65396)), // createPair selector
            abi.encode(MOCK_PAIR)
        );

        token = new Gasccoin();
        vm.stopPrank();
    }

    function test_ExcludeMultipleAccountsFromFees_GasLimitDos() public {
        // Create array that's large enough to exceed gas limit (1500 elements)
        uint256 arrayLength = 1500;
        address[] memory accounts = new address[](arrayLength);
        
        // Generate distinct addresses
        for (uint256 i = 0; i < arrayLength; i++) {
            accounts[i] = address(uint160(i + 10000)); // Non-zero and distinct
        }

        console.log("--- BEFORE-Trigger Transaction ---");
        console.log("Preparing to call 'excludeMultipleAccountsFromFees' with", arrayLength, "addresses at 10M gas");

        console.log("--- Trigger excludeMultipleAccountsFromFees Call ---");
        // Attempt call with realistic mainnet gas limit
        vm.prank(owner);
        (bool success, ) = address(token).call{gas: 10_000_000}(
            abi.encodeWithSelector(
                token.excludeMultipleAccountsFromFees.selector,
                accounts,
                true
            )
        );
        
        console.log("--- AFTER-Trigger Transaction Result ---");
        console.log("Transaction outcome:", success ? "SUCCESS" : "REVERTED (gas exhaustion)");
        
        string memory verdict;
        if (!success) {
            verdict = "Vulnerability Exists: Gas limit exceeded in excludeMultipleAccountsFromFees function";
        } else {
            verdict = "Vulnerability not Exist: excludeMultipleAccountsFromFees completed without gas exhaustion";
        }
        console.log(verdict);
        
        // Verify transaction reverts due to gas exhaustion
        assertFalse(success, "Transaction should fail due to gas exhaustion");
    }
}