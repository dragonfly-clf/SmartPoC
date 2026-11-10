// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DripToken.sol";

contract MaliciousTaxContract {
    function attack() external pure returns (bool) {
        return true;
    }
}

contract DripToken_UntrustedSource_Test is Test {
    DripToken token;
    MaliciousTaxContract maliciousContract;
    address owner = address(0x1);
    
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address mockFactory = address(0xB01FacedFaCe);
    address mockWETH = address(0xC0deF00d);
    address mockPair = address(0xFa57E1eE);

    function setUp() public {
        // Precompute token address based on owner's nonce
        vm.startPrank(owner);
        uint256 nonce = vm.getNonce(owner);
        address precomputedTokenAddress = computeCreateAddress(owner, nonce);

        // Mock router responses without redefining interfaces
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(IUniswapV2Router.factory.selector),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(IUniswapV2Router.WETH.selector),
            abi.encode(mockWETH)
        );

        // Mock factory createPair
        vm.mockCall(
            mockFactory,
            abi.encodeWithSelector(
                IUniswapV2Factory.createPair.selector, 
                precomputedTokenAddress, 
                mockWETH
            ),
            abi.encode(mockPair)
        );

        // Deploy token
        token = new DripToken();
        vm.stopPrank();
        
        // Deploy malicious contract by test contract
        maliciousContract = new MaliciousTaxContract();
    }

    function test_CanSetUntrustedTaxContract() public {
        // Before: get initial tax contract state
        ITaxContract taxContractBefore = token.taxContract();
        console.log("--- BEFORE Trigger ---");
        console.log("Initial tax contract address: %s", address(taxContractBefore));

        console.log("--- Trigger: updateTaxContract ---");
        // Owner sets malicious tax contract
        vm.prank(owner);
        token.updateTaxContract(ITaxContract(address(maliciousContract)));

        // After: get updated tax contract state
        ITaxContract taxContractAfter = token.taxContract();
        console.log("--- AFTER Trigger ---");
        console.log("Updated tax contract address: %s", address(taxContractAfter));

        // Verify state change via assert
        assertEq(
            address(token.taxContract()), 
            address(maliciousContract),
            "Malicious tax contract not set"
        );

        // Differential verification
        if (address(taxContractBefore) != address(taxContractAfter) && 
            address(taxContractAfter) == address(maliciousContract)) {
            console.log("Vulnerability Exists: Tax contract state changed to untrusted address");
        } else {
            console.log("Vulnerability not Exist: No unauthorized state change detected");
        }
    }
}