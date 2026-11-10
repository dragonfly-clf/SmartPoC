// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/xenoX.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

contract MockRouter {
    address public factory;
    address public immutable WETH;
    
    constructor(address _factory) {
        factory = _factory;
        WETH = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    }
}

contract XenoXUninitializedStateTest is Test {
    xenoX public token;
    
    address constant PANCAKE_ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    function setUp() public {
        // Create mock factory and router
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory));
        
        // Set mock router at expected Pancake Router address
        vm.etch(PANCAKE_ROUTER_ADDRESS, address(mockRouter).code);
        
        // Store factory address in router's storage slot 0
        bytes32 factorySlotValue = bytes32(uint256(uint160(address(mockFactory))));
        vm.store(PANCAKE_ROUTER_ADDRESS, bytes32(0), factorySlotValue);
        
        // Deploy token contract
        token = new xenoX();
    }

    function testUninitializedDevTotal() public {
        console.log("--- Verify uninitialized totaldevFees ---");
        uint256 devFees = token.totaldevFees();
        console.log("Current totaldevFees value:", devFees);
        
        // Vulnerability verdict based on static read
        if (devFees == 0) {
            console.log("Vulnerability Exists: totaldevFees is uninitialized (0)");
        } else {
            console.log("Vulnerability not Exist: totaldevFees has been initialized (non-zero)");
        }
        assertEq(devFees, 0, "_tdevTotal should be uninitialized (0)");
    }
}