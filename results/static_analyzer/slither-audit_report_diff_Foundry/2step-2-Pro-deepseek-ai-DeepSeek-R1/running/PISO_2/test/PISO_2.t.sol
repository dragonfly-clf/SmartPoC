// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PISO.sol";

// Mock factory contract
contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x789abc); // Dummy pair address
    }
}

// Mock router contract
contract MockRouter {
    address factoryAddr;
    
    constructor(address _factory) {
        factoryAddr = _factory;
    }
    
    function factory() external view returns (address) {
        return factoryAddr;
    }
    
    function WETH() external pure returns (address) {
        return address(0x123456); // Dummy WETH address
    }
}

// Token that always fails transfers
contract BadToken {
    function transfer(address, uint256) external pure returns (bool) {
        return false;
    }
}

contract PISO_UncheckedTransfer_Test is Test {
    PISO public piso;
    BadToken public badToken;
    address owner = address(0x123);

    function setUp() public {
        // Create mock contracts
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory));
        
        // Deploy PISO with mock router
        vm.prank(owner);
        piso = new PISO(address(mockRouter));
        
        // Deploy bad token that fails transfers
        badToken = new BadToken();
    }
    
    function test_StopAirDrop_UncheckedTransfer() public {
        address recipient = address(0x456);
        bool success;
        
        console.log("--- BEFORE-Trigger ---");
        console.log("State: No state verification applicable for unchecked transfer vulnerability");

        console.log("--- Trigger StopAirDrop ---");
        // Execute a low-level call to avoid reverting entire test
        vm.prank(owner);
        (success,) = address(piso).call(abi.encodeWithSignature("StopAirDrop(address,address,uint256)", address(badToken), recipient, 100));

        console.log("--- AFTER-Trigger ---");
        console.log("Call to StopAirDrop finished without test reverting.");

        // Determine verdict based on call success status
        if (success) {
            // Function did not revert -> vulnerability exists
            console.log("Vulnerability Exists: StopAirDrop did not revert on token transfer failure");
        } else {
            // Function reverted -> vulnerability does not exist
            console.log("Vulnerability not Exist: StopAirDrop reverts on token transfer failure");
        }
    }
}