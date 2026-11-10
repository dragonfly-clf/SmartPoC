// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/deltaace.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234567890ABCDEF);
    }
}

contract MockRouter {
    address public factory;
    address public constant WETH = 0x000000000000000000000000000000000000dEaD;

    constructor() {
        factory = address(new MockFactory());
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata,
        address to,
        uint256 deadline
    ) external {}
}

contract DeltaAceFeeTest is Test {
    deltaace public token;
    address owner = address(0x1);
    address constant DEX_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Create mock router
        MockRouter mockRouter = new MockRouter();
        
        // Set bytecode and storage for the real router address
        vm.etch(DEX_ROUTER, address(mockRouter).code);
        vm.store(
            DEX_ROUTER, 
            bytes32(uint256(0)), 
            bytes32(uint256(uint160(mockRouter.factory())))
        );
        
        // Deploy token contract
        vm.startPrank(owner);
        token = new deltaace();
        vm.stopPrank();
    }

    function test_setMarketingFeeSell_withExcessiveFee() public {
        uint256 excessiveFee = 30; // 30% fee (exceeds 25% limit)
        
        // Logs for differential verification unavailable
        console.log("--- BEFORE-Trigger: Marketing Fee State ---");
        console.log("Note: No public getter for marketingFeeSell available");
        console.log("      Attempting to set fee to 30% (exceeds 25% recommended limit)");

        console.log("--- Trigger: setMarketingFeeSell Execution ---");
        bool vulnerabilityExists;
        string memory reasonMsg;
        
        vm.startPrank(owner);
        try token.setMarketingFeeSell(excessiveFee) {
            vulnerabilityExists = true;
            reasonMsg = "Marketing fee changed to 30% without revert";
        } catch Error(string memory revertReason) {
            vulnerabilityExists = false;
            reasonMsg = string(abi.encodePacked("Reverted: ", revertReason));
        } catch (bytes memory) {
            vulnerabilityExists = false;
            reasonMsg = "Reverted without reason (panic)";
        }
        vm.stopPrank();

        console.log("--- AFTER-Trigger: Call Result ---");
        console.log("Transaction execution result: ", reasonMsg);

        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Owner can bypass marketing fee limit");
        } else {
            console.log("Vulnerability not Exist: Failed to set excessive fee");
        }
    }
}