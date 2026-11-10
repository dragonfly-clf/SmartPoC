// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TravelCoin.sol";

contract MockRouter {
    address public factory;
    address public WETH;

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity) {
        return (0, 0, 0);
    }
}

contract MockFactory {
    address public pair;

    constructor(address _pair) public {
        pair = _pair;
    }

    function createPair(address tokenA, address tokenB) external returns (address) {
        return pair;
    }
}

contract MockPair {}

contract TravelCoinFeeTest is Test {
    TravelCoin token;
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WETH_ADDRESS = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address owner = address(0x1);
    address deployer = address(this);
    
    function setUp() public {
        // Create mock dependencies
        MockPair mockPair = new MockPair();
        MockFactory mockFactory = new MockFactory(address(mockPair));
        MockRouter mockRouter = new MockRouter();

        // Get mock router bytecode using assembly
        address routerAddr = address(mockRouter);
        uint256 size;
        bytes memory code;
        assembly {
            size := extcodesize(routerAddr)
            code := mload(0x40)
            mstore(0x40, add(code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(code, size)
            extcodecopy(routerAddr, add(code, 0x20), 0, size)
        }

        // Create router mock at predefined address
        vm.etch(ROUTER_ADDRESS, code);

        // Set storage variables for mock router
        vm.store(ROUTER_ADDRESS, bytes32(uint256(0)), bytes32(uint256(uint160(address(mockFactory)))));
        vm.store(ROUTER_ADDRESS, bytes32(uint256(1)), bytes32(uint256(uint160(WETH_ADDRESS))));

        // Deploy the token contract
        token = new TravelCoin();

        // Transfer ownership to owner
        vm.prank(deployer);
        token.transferOwnership(owner);
    }

    function testMarketingFeeCanExceed25Percent() public {
        console.log("--- BEFORE-Trigger Fees ---");
        uint256 initialMarketingFee = token.marketingFee();
        console.log("Initial Marketing Fee: %s", initialMarketingFee);

        vm.startPrank(owner);
        
        console.log("--- Trigger ChangeFee ---");
        // Clear all fees
        token.setBUSDRewardsFee(0);
        token.setLiquiditFee(0);
        token.setDeveloperFee(0);
        
        // Set marketing fee to 30% (above 25% limit)
        token.setMarketingFee(30);
        
        vm.stopPrank();

        console.log("--- AFTER-Trigger Fees ---");
        uint256 newMarketingFee = token.marketingFee();
        console.log("New Marketing Fee: %s", newMarketingFee);

        // Verify fee difference and violation
        bool feeChanged = newMarketingFee != initialMarketingFee;
        bool exceedsLimit = newMarketingFee > 25;
        
        console.log("Diff: Marketing Fee changed? %s", feeChanged ? "YES" : "NO");
        console.log("Safety Limit Violated? %s", exceedsLimit ? "YES" : "NO");

        // Final vulnerability verdict
        if (exceedsLimit) {
            console.log("Vulnerability Exists: Marketing fee exceeds 25%% safety limit");
        } else {
            console.log("Vulnerability not Exist: Marketing fee within 25%% safety limit");
        }
    }
}