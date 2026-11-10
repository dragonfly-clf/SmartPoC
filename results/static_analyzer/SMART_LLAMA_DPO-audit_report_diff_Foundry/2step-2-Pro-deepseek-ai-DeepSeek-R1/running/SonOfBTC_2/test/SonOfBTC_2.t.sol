// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SonOfBTC.sol";

contract SonOfBTCAuditTest is Test {
    // Mock router and factory to avoid mainnet dependencies
    address private constant MOCK_FACTORY_ADDRESS = address(0xFaC710);
    address private constant MOCK_ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private constant MOCK_PAIR_ADDRESS = address(0xFeEDb0);
    
    SonOfBTC token;
    address owner = vm.addr(1);
    address presaler = 0x81089Ed7fA92390F1a74400718fB8d916c10d082;
    address userA = vm.addr(2);

    function setUp() public {
        // Deploy mock router with mock factory
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory));
        
        // Patch real router address with mock code
        vm.etch(MOCK_ROUTER_ADDRESS, address(mockRouter).code);
        vm.etch(MOCK_FACTORY_ADDRESS, address(mockFactory).code);

        vm.startPrank(owner);
        token = new SonOfBTC();
        token.authorize(owner);
        
        // Disable features that require router functionality
        token.setAutoBuybackSettings(false, 0, 0, 0, false);
        token.setFees(0, 0, 0, 0, 100);
        token.setSwapBackSettings(false, 0);
        
        // Remove tx limits for setup
        token.setTxLimit(token.totalSupply());
        
        // Distribute tokens from presaler to test user
        uint256 transferAmount = token.totalSupply() / 100;
        vm.stopPrank();
        vm.prank(presaler);
        token.transfer(userA, transferAmount);
    }

    function testTxLimitArbitraryReduction() public {
        uint256 totalSupply = token.totalSupply();
        uint256 initialLimit = totalSupply / 500; // 0.2%
        uint256 reducedLimit = totalSupply / 1000; // 0.1%
        uint256 validTransfer = initialLimit * 3 / 4; // 75% of initial limit

        // Set initial limit
        vm.prank(owner);
        token.setTxLimit(initialLimit);
        
        console.log("--- BEFORE-Trigger: Transfer under initial limit ---");
        // Verify transfer succeeds before reduction
        vm.prank(userA);
        (bool successBefore,) = address(token).call(
            abi.encodeWithSignature(
                "transfer(address,uint256)", 
                address(this), 
                validTransfer
            )
        );
        console.log("Transfer result before reduction:", successBefore ? "Success" : "Failure");

        console.log("--- Trigger: Reduce txLimit to", reducedLimit, "---");
        // Perform critical reduction action
        vm.prank(owner);
        token.setTxLimit(reducedLimit);
        
        console.log("--- AFTER-Trigger: Transfer same amount under reduced limit ---");
        // Verify transfer fails after reduction
        vm.prank(userA);
        (bool successAfter,) = address(token).call(
            abi.encodeWithSignature(
                "transfer(address,uint256)", 
                address(this), 
                validTransfer
            )
        );
        console.log("Transfer result after reduction:", successAfter ? "Success" : "Failure");

        console.log("--- Differential Validation ---");
        console.log("Behavior changed: [Before:", successBefore, "- After:", successAfter, "]");
        if (successBefore && !successAfter) {
            console.log("Vulnerability Exists: Transaction limit reduction caused transfer reversion");
        } else {
            console.log("Vulnerability not Exist: Transfer behavior unchanged after limit reduction");
        }
    }

    function testSwapbackEnableWithZeroThreshold() public {
        // Owner sets fees to non-zero to ensure contract gets token balance during transfer
        vm.startPrank(owner);
        token.setFees(1, 1, 1, 1, 100);
        token.setSwapBackSettings(true, 0);
        vm.stopPrank();

        // UserA transfers tokens to someone to incur fees (so contract gets tokens)
        uint256 transferAmount = 1000 * 10 ** token.decimals();
        uint256 senderBalance = token.balanceOf(userA);
        if (transferAmount > senderBalance) {
            transferAmount = senderBalance / 10;
        }

        // Expect revert with expected message from mock router
        vm.prank(userA);
        vm.expectRevert("MockRouter: ZERO_AMOUNT");
        token.transfer(address(1), transferAmount);

        // Final vulnerability verdict
        console.log("Vulnerability Exists: Zero-threshold swapback causes transfer reverts");
    }
}

// Mock contracts to simulate router/factory
contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xFeEDb0);
    }
}

contract MockRouter {
    address public immutable factory;
    
    constructor(address _factory) {
        factory = _factory;
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint, address[] calldata, address to, uint
    ) external payable {}

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint, /*amountOutMin*/
        address[] calldata, /*path*/
        address, /*to*/
        uint /*deadline*/
    ) external view {
        require(amountIn > 0, "MockRouter: ZERO_AMOUNT");
    }

    function addLiquidityETH(
        address, uint, uint, uint, address, uint
    ) external payable returns (uint, uint, uint) {
        return (0,0,0);
    }
}