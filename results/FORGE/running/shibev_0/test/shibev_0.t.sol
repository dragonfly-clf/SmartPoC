// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ShibaElonVerse.sol";

contract MockERC20 {
    function balanceOf(address) public pure returns (uint256) {
        return 0;
    }
}

contract MockFactory {
    address public pair;
    
    constructor(address _pair) {
        pair = _pair;
    }
    
    function createPair(address, address) external view returns (address) {
        return pair;
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

contract MockPair {}

contract ShibaElonVerseFeeTest is Test {
    ShibaElonVerse token;
    address owner = makeAddr("owner");
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Deploy mock ecosystem
        MockERC20 weth = new MockERC20();
        MockPair mockPair = new MockPair();
        MockFactory mockFactory = new MockFactory(address(mockPair));
        MockRouter mockRouter = new MockRouter(address(mockFactory), address(weth));
        
        // Patch router with complete mock implementation
        vm.etch(routerAddress, address(mockRouter).code);

        // Deploy token - should now work with mocks
        vm.startPrank(owner);
        token = new ShibaElonVerse();
        vm.stopPrank();
    }

    function test_FeesCanExceed25PercentLimit() public {
        console.log("--- BEFORE-Trigger FeeState ---");
        (uint16 beforeReward, uint16 beforeMarketing, uint16 beforeBurn) = token.buyFee();
        uint16 beforeTotalFee = beforeReward + beforeMarketing + beforeBurn;
        console.log("Pre-trigger total fee:", beforeTotalFee);
        console.log("Pre-trigger reward fee:", beforeReward);
        console.log("Pre-trigger marketing fee:", beforeMarketing);
        console.log("Pre-trigger burn fee:", beforeBurn);

        console.log("--- Trigger setBuyFees ---");
        // Attempt to set fees to 26% (10000 = 100% basis points)
        uint16 rewardFee = 1300; // 13%
        uint16 marketingFee = 1300; // 13%
        uint16 burnFee = 0;

        // Owner sets fees beyond 25% limit
        vm.startPrank(owner);
        token.setBuyFees(rewardFee, marketingFee, burnFee);
        vm.stopPrank();

        console.log("--- AFTER-Trigger FeeState ---");
        (uint16 afterReward, uint16 afterMarketing, uint16 afterBurn) = token.buyFee();
        uint16 afterTotalFee = afterReward + afterMarketing + afterBurn;
        console.log("Post-trigger total fee:", afterTotalFee);
        console.log("Post-trigger reward fee:", afterReward);
        console.log("Post-trigger marketing fee:", afterMarketing);
        console.log("Post-trigger burn fee:", afterBurn);

        // Validate vulnerability
        if (afterTotalFee > 2500) {
            console.log("Vulnerability Exists: Fees exceed maximum threshold of 2500 basis points (total: %s)", afterTotalFee);
        } else {
            console.log("Vulnerability not Exist: Fees remain within limit (total: %s)", afterTotalFee);
        }
    }
}