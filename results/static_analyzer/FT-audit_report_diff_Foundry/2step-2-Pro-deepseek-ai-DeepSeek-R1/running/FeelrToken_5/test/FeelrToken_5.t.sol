// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FeelrToken.sol";

contract MockRouter {
    address public factory;
    address public weth;
    
    function setFactory(address _factory) public {
        factory = _factory;
    }

    function setWETH(address _weth) public {
        weth = _weth;
    }

    function WETH() external view returns (address) {
        return weth;
    }
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256, // amountIn
        uint256, // amountOutMin
        address[] calldata, // path
        address, // to
        uint256 // deadline
    ) external {
        // Gas bomb: Consume large amount of gas (2.4M units)
        uint256 start = gasleft();
        while (start - gasleft() < 2_400_000) {
            continue;
        }
    }
}

contract MockFactory {
    address public pair;
    
    function setPair(address _pair) public {
        pair = _pair;
    }
    
    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockPair {}
contract MockWETH {}

contract GasExhaustionTest is Test {
    FeelrToken token;
    address owner = makeAddr("owner");
    address marketing = makeAddr("marketing");
    MockRouter mockRouter;
    MockFactory mockFactory;
    MockPair mockPair;
    MockWETH mockWETH;
    address constant ROUTER_ADDR = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    function setUp() public {
        // Deploy mocks
        mockWETH = new MockWETH();
        mockFactory = new MockFactory();
        mockRouter = new MockRouter();
        mockPair = new MockPair();
        
        // Configure mocks
        mockRouter.setFactory(address(mockFactory));
        mockRouter.setWETH(address(mockWETH));
        mockFactory.setPair(address(mockPair));
        
        // Patch router code to fixed address
        vm.etch(ROUTER_ADDR, address(mockRouter).code);
        
        // Create router interface for state configuration
        MockRouter router = MockRouter(ROUTER_ADDR);
        router.setFactory(address(mockFactory));
        router.setWETH(address(mockWETH));
        
        // Deploy and configure token
        vm.startPrank(owner);
        token = new FeelrToken();
        token.updateAddresses(marketing);
        token.setMinTokenToSwap(1 * 10 ** token.decimals());
        token.includeOrExcludeFromFee(address(token), true);
        token.enableTrading();
        token.setDistributionStatus(true);
        
        // Fund token contract to trigger distribution logic
        uint256 amount = 100_000 * 10 ** token.decimals();
        deal(address(token), owner, amount * 2);
        token.transfer(address(token), amount);
        
        vm.stopPrank();
    }

    function testGasExhaustion() public {
        // Set insufficient gas limit to trigger out-of-gas
        uint256 gasLimit = 400_000;
        address from = owner;
        address to = makeAddr("receiver");
        uint256 transferAmount = 1 * 10 ** token.decimals();
        
        console.log("--- BEFORE-Trigger ---");
        console.log("Initial gas limit:", gasLimit);
        console.log("Transfer amount:", transferAmount);
        
        console.log("--- Trigger Transfer ---");
        vm.prank(from);
        (bool success, ) = address(token).call{gas: gasLimit}(
            abi.encodeWithSelector(
                token.transfer.selector,
                to,
                transferAmount
            )
        );
        
        console.log("--- AFTER-Trigger ---");
        if (!success) {
            console.log("Vulnerability Exists: Transfer failed due to excessive gas consumption with gas limit %s", gasLimit);
        } else {
            console.log("Vulnerability not Exist: Transfer succeeded with gas limit %s", gasLimit);
        }
    }
}