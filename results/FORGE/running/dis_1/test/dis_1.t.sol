// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Disney.sol";

contract DisneyTest is Test {
    Disney public token;
    address owner = address(0x1234);
    address recipient = address(0x5678);

    function setUp() public {
        // Deploy Disney implementation contract
        Disney implementation = new Disney();
        
        // Deploy UUPS-compatible proxy
        address proxy = deployProxy(
            address(implementation),
            abi.encodeWithSelector(Disney.initialize.selector)
        );
        
        token = Disney(proxy);
        
        // Transfer ownership from deployer (this test contract) to desired owner
        vm.prank(address(this));
        token.transferOwnership(owner);
    }

    function testUnlimitedMintingVulnerability() public {
        uint96 EXPONENT = uint96(10)**token.decimals();
        uint256 MASSIVE_AMOUNT = 1_000_000_000 * EXPONENT;
        
        // Pre-Attack State Capture
        console.log("--- BEFORE-Trigger Mint ---");
        uint256 initialSupply = token.totalSupply();
        uint256 initialBalance = token.balanceOf(recipient);
        console.log("Initial total supply: %s", initialSupply);
        console.log("Initial recipient balance: %s", initialBalance);

        console.log("--- Trigger Mint ---");
        console.log("Minting %s tokens to recipient", MASSIVE_AMOUNT);
        
        // Vulnerability Trigger
        vm.prank(owner);
        token.mint(recipient, MASSIVE_AMOUNT);

        // Post-Attack State Capture
        console.log("--- AFTER-Trigger Mint ---");
        uint256 newSupply = token.totalSupply();
        uint256 newBalance = token.balanceOf(recipient);
        console.log("New total supply: %s", newSupply);
        console.log("New recipient balance: %s", newBalance);

        // Differential Validation
        uint256 actualSupplyChange = newSupply - initialSupply;
        uint256 actualBalanceChange = newBalance - initialBalance;
        bool supplyVulnerable = actualSupplyChange == MASSIVE_AMOUNT;
        bool balanceVulnerable = actualBalanceChange == MASSIVE_AMOUNT;
        bool vulnerabilityExists = supplyVulnerable && balanceVulnerable;

        console.log("--- State Change Verification ---");
        console.log("Actual supply increase: %s | Expected: %s", actualSupplyChange, MASSIVE_AMOUNT);
        console.log("Actual balance increase: %s | Expected: %s", actualBalanceChange, MASSIVE_AMOUNT);

        // Final Verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Owner can mint unlimited tokens without restriction");
        } else {
            console.log("Vulnerability not Exist: Minting restrictions are properly enforced");
        }

        // Original Assertions (preserved)
        assertEq(newSupply, initialSupply + MASSIVE_AMOUNT);
        assertEq(newBalance, initialBalance + MASSIVE_AMOUNT);
    }

    // UUPS-compatible deployment helper
    function deployProxy(address impl, bytes memory data) internal returns (address) {
        bytes memory deployment = abi.encodePacked(
            hex"3d602d80600a3d3981f3363d3d373d3d3d363d73",
            impl,
            hex"5af43d82803e903d91602b57fd5bf3"
        );
        address proxy;
        assembly {
            proxy := create(0, add(deployment, 0x20), mload(deployment))
            if iszero(gt(extcodesize(proxy), 0)) {
                revert(0, 0)
            }
        }
        
        if (data.length > 0) {
            (bool success, bytes memory result) = proxy.call(data);
            if (!success) {
                if (result.length > 0) {
                    revert(string(result));
                } else {
                    revert("Initialization failed");
                }
            }
        }
        return proxy;
    }
}