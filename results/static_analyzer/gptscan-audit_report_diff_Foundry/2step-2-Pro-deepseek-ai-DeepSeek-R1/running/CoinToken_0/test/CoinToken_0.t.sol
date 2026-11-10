// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external returns (address) {
        return address(0x123);
    }
}

contract MockUniswapV2Router {
    MockUniswapV2Factory public factory;
    address public immutable WETH;
    bool public manipulateSwap;

    event SwapError(string message);

    constructor() {
        factory = new MockUniswapV2Factory();
        WETH = address(0xDEADBEEF);
    }

    receive() external payable {}

    function setManipulateSwap(bool status) external {
        manipulateSwap = status;
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256,
        uint256,
        address[] calldata,
        address to,
        uint256
    ) external payable {
        try this.handleSwap(to) {} catch Error(string memory reason) {
            emit SwapError(reason);
        }
    }

    function handleSwap(address to) external {
        uint256 amountToSend = manipulateSwap ? 1 : 1 ether;
        require(
            address(this).balance >= amountToSend,
            "Insufficient router ETH"
        );
        payable(to).transfer(amountToSend);
    }

    function addLiquidityETH(
        address,
        uint256,
        uint256,
        uint256,
        address,
        uint256
    ) external payable returns (uint256, uint256, uint256) {
        if (manipulateSwap) {
            return (0, 0, 0);
        }
        return (0, 0, 0);
    }
}

contract CoinTokenSlippageTest is Test {
    CoinToken token;
    MockUniswapV2Router router;
    address deployer = address(0x1);
    address feeReceiver = address(0x3);
    address tokenOwner = address(0x4);
    uint256 constant INITIAL_SUPPLY = 1_000_000 ether;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );

    function setUp() public {
        vm.deal(deployer, 100 ether);
        vm.deal(tokenOwner, 1_000 ether);

        router = new MockUniswapV2Router();
        payable(address(router)).transfer(10 ether);

        vm.startPrank(deployer);
        token = new CoinToken(
            "TestToken",
            "TTK",
            18,
            INITIAL_SUPPLY / 1 ether,
            1,
            10,
            1,
            address(router),
            feeReceiver,
            tokenOwner,
            address(0)
        );
        vm.stopPrank();

        vm.startPrank(tokenOwner);
        token.setSwapAndLiquifyEnabled(true);
        token.setNumTokensSellToAddToLiquidity(100 ether);
        token.transfer(address(token), 100 ether);
        vm.stopPrank();

        router.setManipulateSwap(true);
    }

    function testSandwichAttack() public {
        uint256 snapshot = vm.snapshot();
        
        vm.startPrank(tokenOwner);
        console.log("--- Trigger Transfer (Attacker Action) ---");
        vm.recordLogs();
        token.transfer(address(0xdead), 1);
        Vm.Log[] memory logs = vm.getRecordedLogs();
        vm.stopPrank();

        console.log("--- Post-Trigger Event Analysis ---");
        bytes32 expectedEvent = keccak256("SwapAndLiquify(uint256,uint256,uint256)");
        bool vulnerabilityTriggered = false;
        
        for (uint256 i; i < logs.length; i++) {
            if (logs[i].topics[0] == expectedEvent) {
                (uint256 swapped, uint256 received, uint256 liquidity) = 
                    abi.decode(logs[i].data, (uint256, uint256, uint256));
                console.log("Event Found: tokensSwapped=%s, ethReceived=%s, tokensIntoLiquidity=%s", swapped, received, liquidity);
                if (swapped == 50 ether && received == 1 && liquidity == 50 ether) {
                    vulnerabilityTriggered = true;
                    console.log("VULNERABILITY CONFIRMED: Malicious slippage values detected");
                    break;
                }
            }
        }

        console.log("--- Final Verdict ---");
        if (vulnerabilityTriggered) {
            console.log("Vulnerability Exists: Attack triggered SwapAndLiquify event with manipulated ETH value (1 wei)");
        } else {
            console.log("Vulnerability not Exist: Critical event not emitted with exploit parameters");
        }

        vm.revertTo(snapshot);
    }
}