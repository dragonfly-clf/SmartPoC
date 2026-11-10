// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PuppySwapToken.sol";

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(uint160(uint256(keccak256("mock_pair"))));
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory) public {
        factory = _factory;
        WETH = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    }
}

contract PuppySwapTokenTest is Test {
    PuppySwapToken token;
    address owner;
    MockFactory mockFactory;
    MockRouter mockRouter;
    
    uint256 constant EXCLUDED_COUNT = 3000; // Large enough to trigger OOG

    function setUp() public {
        owner = address(this);
        // Deploy mocks
        mockFactory = new MockFactory();
        mockRouter = new MockRouter(address(mockFactory));
        
        // Deploy token with mock router
        token = new PuppySwapToken(payable(address(mockRouter)));
        
        // Fill excluded addresses array (as owner)
        for (uint256 i = 0; i < EXCLUDED_COUNT; i++) {
            address account = address(uint160(i + 100)); 
            vm.prank(owner);
            token.excludeFromReward(account);
        }
    }

    function testIncludeInRewardGasExhaustion() public {
        address target = address(uint160(100 + EXCLUDED_COUNT - 1)); // Last added
        uint256 gasToUse = 5_000_000; // 5 million gas limit
        
        console.log("--- Trigger Action: includeInReward call ---");
        vm.prank(owner);
        (bool success,) = address(token).call{gas: gasToUse}(
            abi.encodeWithSignature("includeInReward(address)", target)
        );
        
        if (!success) {
            console.log("Vulnerability Exists: includeInReward exhausts gas with large excluded array");
        } else {
            console.log("Vulnerability not Exist: includeInReward completes within gas limit");
        }
    }

    function testGetCurrentSupplyGasExhaustion() public {
        uint256 rAmount = 1;
        uint256 gasToUse = 10_000_000; // 10 million gas limit
        
        console.log("--- Trigger Action: tokenFromReflection staticcall ---");
        (bool success,) = address(token).staticcall{gas: gasToUse}(
            abi.encodeWithSignature("tokenFromReflection(uint256)", rAmount)
        );
        
        if (!success) {
            console.log("Vulnerability Exists: tokenFromReflection exhausts gas with large excluded array");
        } else {
            console.log("Vulnerability not Exist: tokenFromReflection completes within gas limit");
        }
    }
}