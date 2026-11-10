// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Munkai.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x567);
    }
}

contract MockRouter is IDEXRouter {
    bool public swapCalled;
    uint256 public lastSwapValue;
    address public lastToAddress;
    uint256 public lastAmountOutMin;
    uint256 public lastDeadline;

    function factory() external pure override returns (address) {
        return address(0x123);
    }

    function WETH() external pure override returns (address) {
        return address(0x1234);
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable override {
        swapCalled = true;
        lastSwapValue = msg.value;
        lastToAddress = to;
        lastAmountOutMin = amountOutMin;
        lastDeadline = deadline;
    }

    function addLiquidityETH(
        address,
        uint256,
        uint256,
        uint256,
        address,
        uint256
    ) external payable override returns (uint256, uint256, uint256) {
        return (0, 0, 0);
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256,
        uint256,
        address[] calldata,
        address,
        uint256
    ) external override {}

    function addLiquidity(
        address,
        address,
        uint256,
        uint256,
        uint256,
        uint256,
        address,
        uint256
    ) external override returns (uint256, uint256, uint256) {
        return (0, 0, 0);
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256,
        uint256,
        address[] calldata,
        address,
        uint256
    ) external override {}
}

contract MunkaiTest is Test {
    Munkai token;
    MockRouter mockRouter;
    address constant owner = address(0x1);
    address constant user = address(0x123);
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant MOCK_FACTORY_ADDRESS = address(0x123);
    address constant MOCK_WETH_ADDRESS = address(0x1234);

    function setUp() public {
        // Deploy MockFactory and setup its code at fixed address
        MockFactory mockFactory = new MockFactory();
        vm.etch(MOCK_FACTORY_ADDRESS, address(mockFactory).code);

        // Deploy mock router
        mockRouter = new MockRouter();

        // Deploy token with mocked router
        vm.prank(owner);
        token = new Munkai(address(mockRouter));

        // Grant authorization to test contract
        vm.prank(owner);
        token.authorize(address(this));
    }

    function testAutoBuybackIsVulnerableToSandwichAttack() public {
        uint256 buybackAmount = 1 ether;

        // Verify initial state
        console.log("--- BEFORE-Trigger Auto Buyback ---");
        console.log("swapCalled state: %s", mockRouter.swapCalled());
        console.log("lastAmountOutMin: %s", mockRouter.lastAmountOutMin());
        console.log("lastDeadline: %s", mockRouter.lastDeadline());
        require(!mockRouter.swapCalled(), "Swap should not be called initially");

        // Configure auto-buyback settings
        vm.prank(owner);
        token.setAutoBuybackSettings(true, buybackAmount * 10, buybackAmount, 0);
        console.log("--- Trigger Auto Buyback Config ---");
        console.log("* setAutoBuybackSettings(true, %s, %s, 0)", buybackAmount * 10, buybackAmount);

        // Fund token contract with ETH for buyback
        vm.deal(address(token), buybackAmount);
        console.log("--- Trigger Auto Buyback Funding ---");
        console.log("* Funding token with: %s ETH", buybackAmount);

        // Transfer tokens to trigger auto-buyback
        vm.prank(owner);
        token.transfer(user, 1);
        console.log("--- Trigger Auto Buyback Transfer ---");
        console.log("* Transferring 1 token to user");

        // Verify post-trigger vulnerability parameters
        console.log("--- AFTER-Trigger Auto Buyback ---");
        console.log("swapCalled state: %s", mockRouter.swapCalled());
        console.log("lastAmountOutMin: %s", mockRouter.lastAmountOutMin());
        console.log("lastDeadline: %s", mockRouter.lastDeadline());
        
        bool vulnerable = mockRouter.swapCalled() && 
                          mockRouter.lastAmountOutMin() == 0 && 
                          mockRouter.lastDeadline() == block.timestamp;
        
        if (vulnerable) {
            console.log("Vulnerability Exists: Buyback executes with zero slippage protection");
        } else {
            console.log("Vulnerability not Exist: Safe swap parameters detected");
        }

        // Final verdict assertion
        assertTrue(vulnerable, "The auto-buyback mechanism is vulnerable to sandwich attacks");
    }

    function testManualBuybackIsVulnerableToSandwichAttack() public {
        uint256 buybackAmount = 2 ether;

        console.log("--- BEFORE-Trigger Manual Buyback ---");
        console.log("swapCalled state: %s", mockRouter.swapCalled());
        console.log("lastAmountOutMin: %s", mockRouter.lastAmountOutMin());
        console.log("lastDeadline: %s", mockRouter.lastDeadline());
        require(!mockRouter.swapCalled(), "Swap should not be called initially");

        // Fund token contract with ETH
        vm.deal(address(token), buybackAmount);
        console.log("--- Trigger Manual Buyback Funding ---");
        console.log("* Funding token with: %s ETH", buybackAmount);

        // Trigger manual buyback
        token.triggerZeusBuyback(buybackAmount, false);
        console.log("--- Trigger Manual Buyback Call ---");
        console.log("* triggerZeusBuyback(%s, false)", buybackAmount);

        console.log("--- AFTER-Trigger Manual Buyback ---");
        console.log("swapCalled state: %s", mockRouter.swapCalled());
        console.log("lastAmountOutMin: %s", mockRouter.lastAmountOutMin());
        console.log("lastDeadline: %s", mockRouter.lastDeadline());
        
        bool vulnerable = mockRouter.swapCalled() && 
                          mockRouter.lastAmountOutMin() == 0 && 
                          mockRouter.lastDeadline() == block.timestamp;
        
        if (vulnerable) {
            console.log("Vulnerability Exists: Manual buyback executes with zero slippage protection");
        } else {
            console.log("Vulnerability not Exist: Safe swap parameters in manual buyback");
        }

        assertTrue(vulnerable, "The manual buyback mechanism is vulnerable to sandwich attacks");
    }
}