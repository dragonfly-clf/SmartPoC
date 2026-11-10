// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/KARMA.sol";

contract MockWETH {
    function deposit() public payable {}
}

contract MockPair {
    function token0() external pure returns (address) { return address(0); }
    function token1() external pure returns (address) { return address(0); }
    function getReserves() external pure returns (uint112, uint112, uint32) { return (0, 0, 0); }
}

contract MockFactory {
    mapping(address => mapping(address => address)) public getPair;
    address public pair;

    constructor(address _pair) {
        pair = _pair;
    }

    function setPairs(address tokenA, address tokenB, address _pair) external {
        getPair[tokenA][tokenB] = _pair;
        getPair[tokenB][tokenA] = _pair;
    }

    function createPair(address tokenA, address tokenB) external returns (address) {
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

    function getAmountsOut(uint, address[] memory) external pure returns (uint[] memory amounts) {
        amounts = new uint[](2);
        amounts[0] = 1 ether;
        amounts[1] = 1 ether;
        return amounts;
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external {}
}

contract KARMAZeroDivisionTest is Test {
    KARMA token;
    address owner = address(0x1);
    address user1 = address(0x2);
    address user2 = address(0x3);
    IUniswapV2Router02 public router;
    MockFactory public factory;
    MockWETH public weth;
    MockRouter public mockRouter;
    MockPair public pair;
    address constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    function setUp() public {
        // Set chain ID to Ethereum mainnet
        vm.chainId(1);
        
        // Deploy mock contracts
        weth = new MockWETH();
        pair = new MockPair();
        factory = new MockFactory(address(pair));
        mockRouter = new MockRouter(address(factory), address(weth));

        // Set up storage at the real router address
        vm.etch(ROUTER, address(mockRouter).code);
        router = IUniswapV2Router02(ROUTER);

        vm.startPrank(owner);
        token = new KARMA();
        
        // Mint initial tokens to user1
        uint256 balance = token.balanceOf(owner);
        token.transfer(user1, balance / 10);
        vm.stopPrank();
    }

    function testZeroDivisionFailure() public {
        vm.startPrank(owner);
        // Disable wallet-to-wallet fee exemption
        token.enableWalletToWalletTransferWithoutFee(false);
        
        // Set all buy fees to zero
        token.setBuyFeePercentages(0,0,0,0);
        
        // Set all sell fees to zero
        token.setSellFeePercentages(0,0,0,0);
        vm.stopPrank();

        // Attempt transfer with zero fees
        uint256 transferAmount = token.balanceOf(user1) / 10;
        
        vm.startPrank(user1);
        console2.log("--- Trigger Transfer ---");
        bool reverted;
        try token.transfer(user2, transferAmount) {
            reverted = false;
        } catch {
            reverted = true;
        }
        vm.stopPrank();

        // Verify vulnerability existence via revert
        if (reverted) {
            console2.log("Vulnerability Exists: division by zero occurs");
        } else {
            console2.log("Vulnerability not Exist: transfer succeeded without division by zero");
            assertFalse(true, "Transfer should revert due to division by zero");
        }
    }
}