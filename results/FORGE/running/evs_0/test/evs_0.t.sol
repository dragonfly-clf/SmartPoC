// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Ecoverse.sol";

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0x123);
    }
}

contract MockRouter {
    address public factory;
    address public WETH;
    
    constructor(address _factory, address _WETH) public {
        factory = _factory;
        WETH = _WETH;
    }
}

contract EcoverseFeeManipulationTest is Test {
    Ecoverse token;
    address owner = address(0x1);
    
    // Hardcoded router address from Ecoverse constructor
    address constant UNISWAP_ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    function getRuntimeCode(address _addr) internal view returns (bytes memory) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        bytes memory code = new bytes(size);
        assembly {
            extcodecopy(_addr, add(code, 0x20), 0, size)
        }
        return code;
    }
    
    function setUp() public {
        // Deploy mock dependencies
        MockFactory mockFactory = new MockFactory();
        address mockWETH = address(0xBEEF);
        MockRouter mockRouter = new MockRouter(address(mockFactory), mockWETH);
        
        // Get runtime code of mock router
        bytes memory routerCode = getRuntimeCode(address(mockRouter));
        
        // Override target router address with mock bytecode
        vm.etch(UNISWAP_ROUTER_ADDRESS, routerCode);
        
        // Manually initialize mock storage at router address
        vm.store(
            UNISWAP_ROUTER_ADDRESS,
            bytes32(uint256(0)), // factory storage slot
            bytes32(uint256(uint160(address(mockFactory)))) // value
        );
        vm.store(
            UNISWAP_ROUTER_ADDRESS,
            bytes32(uint256(1)), // WETH storage slot
            bytes32(uint256(uint160(mockWETH))) // value
        );
        
        // Deploy token contract as owner
        vm.startPrank(owner);
        token = new Ecoverse();
        vm.stopPrank();
    }
    
    function testOwnerCanSetFeeAbove25Percent() public {
        uint256 invalidFee = 26; // Exceeds 25% limit
        console.log("--- BEFORE-Trigger DevelopmentFee ---");
        uint256 feeBefore = token._DevelopmentFee();
        console.log("Development Fee before setting:", feeBefore);
        
        console.log("--- Trigger setDevelopmentFee ---");
        // Verify owner can set fee beyond allowed limit
        vm.prank(owner);
        token.setDevelopmentFee(invalidFee);
        
        console.log("--- AFTER-Trigger DevelopmentFee ---");
        uint256 feeAfter = token._DevelopmentFee();
        console.log("Development Fee after setting:", feeAfter);
        
        // Final vulnerability verdict
        if (feeAfter == invalidFee) {
            console.log("Vulnerability Exists: Fee was successfully set beyond 25%% limit");
        } else {
            console.log("Vulnerability not Exist: Fee change was prevented");
        }
    }
}