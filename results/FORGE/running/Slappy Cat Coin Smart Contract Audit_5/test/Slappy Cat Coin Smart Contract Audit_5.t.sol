// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SlappyCat.sol";

contract MockWETH {
    function deposit() external payable {}
    function transfer(address, uint256) external pure returns (bool) { return true; }
}

contract MockPair {}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(new MockPair());
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract SlappyCatTest is Test {
    SlappyCat token;
    MockFactory mockFactory;
    MockRouter mockRouter;
    address mockWETH;
    address owner;
    
    address[] private accounts;
    address private constant TARGET_ACCOUNT = address(0x1234);
    uint256 private constant EXCLUSION_COUNT = 200;
    address private constant CHAIN97_ROUTER = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;

    function setUp() public {
        // Set chain ID to 97 to match the contract's condition
        vm.chainId(97);
        owner = makeAddr("owner");
        
        // Deploy mocks
        mockFactory = new MockFactory();
        mockWETH = address(new MockWETH());
        mockRouter = new MockRouter(address(mockFactory), mockWETH);
        
        // Inject mock router at chain-specific address
        vm.etch(CHAIN97_ROUTER, address(mockRouter).code);
        
        // Deploy token as owner and perform all privileged operations
        vm.startPrank(owner);
        token = new SlappyCat();
        
        // Create and populate exclusion list
        for (uint256 i = 0; i < EXCLUSION_COUNT; i++) {
            address account = address(uint160(uint256(keccak256(abi.encodePacked(i)))));
            token.excludeFromReward(account);
            accounts.push(account);
        }
        
        // Exclude target account last
        token.excludeFromReward(TARGET_ACCOUNT);
        vm.stopPrank();
    }

    function testIncludeInRewardHighGasCost() public {
        console.log("--- BEFORE-Trigger ---");
        bool isExcludedBefore = token.isExcludedFromReward(TARGET_ACCOUNT);
        console.log("Target account excluded (before):", isExcludedBefore);
        assertTrue(isExcludedBefore, "Account should be excluded initially");

        console.log("--- Trigger includeInReward ---");
        // Measure gas cost of removing exclusion
        vm.startPrank(owner);
        uint256 gasStart = gasleft();
        token.includeInReward(TARGET_ACCOUNT);
        uint256 gasUsed = gasStart - gasleft();
        vm.stopPrank();
        console.log("Gas used for includeInReward:", gasUsed);

        console.log("--- AFTER-Trigger ---");
        bool isExcludedAfter = token.isExcludedFromReward(TARGET_ACCOUNT);
        console.log("Target account excluded (after):", isExcludedAfter);
        assertFalse(isExcludedAfter, "Account should be included after operation");

        // Vulnerability assessment based on gas consumption
        uint256 gasThreshold = 200_000; // Dev-defined acceptable gas limit
        if (gasUsed > gasThreshold) {
            console.log("Vulnerability Exists: includeInReward gas cost exceeds safe threshold (200k gas)");
        } else {
            console.log("Vulnerability not Exist: Gas consumption within acceptable limits");
        }
    }
}