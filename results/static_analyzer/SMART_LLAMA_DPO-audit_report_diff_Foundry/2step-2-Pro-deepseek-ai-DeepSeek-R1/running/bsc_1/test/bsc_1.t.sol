// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/bsc.sol";

contract MockERC20 {
    function balanceOf(address) public pure returns (uint256) {
        return type(uint256).max;
    }
}

contract MockWETH {
    function deposit() public payable {}
    function transfer(address, uint256) public pure returns (bool) {
        return true;
    }
    function withdraw(uint256) public {}
}

contract MockFactory {
    function createPair(address, address) public pure returns (address) {
        return address(0xC0FFEE);
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
    
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint, uint, uint) {
        return (0,0,0);
    }
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external {}
}

contract bscTest is Test {
    bsc token;
    address owner = address(0x1);
    address user = address(0x2);
    address receiveAddress = address(0x3);

    function setUp() public {
        // Deploy mocks
        MockFactory factory = new MockFactory();
        MockWETH weth = new MockWETH();
        MockRouter router = new MockRouter(address(factory), address(weth));

        // Patch the hardcoded router address to point to our mock
        vm.etch(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), address(router).code);
        
        // Deploy token
        vm.startPrank(owner);
        token = new bsc();
        
        // Configure token
        token.setBuyTaxes(10, 0, 0);
        token.setSellTaxes(10, 0, 0);
        token.setSwapAndLiquifyEnabled(false);
        token.setMarketPairStatus(address(token), true);
        token.setIsExcludedFromFee(address(token), false);
        token.Launch();  // Enable token transfers
        
        // Fund contract with tokens
        token.transfer(address(token), 1000 ether);
        vm.stopPrank();
    }

    function testDoubleFeeOnContractTransfer() public {
        console.log("--- BEFORE-Trigger Transfer ---");
        // Verify initial state
        uint256 contractBalBefore = token.balanceOf(address(token));
        uint256 receiveBalBefore = token.balanceOf(receiveAddress);
        console.log("Contract balance before:", contractBalBefore);
        console.log("ReceiveAddress balance before:", receiveBalBefore);
        assertEq(contractBalBefore, 1000 ether, "initial contract balance");
        
        console.log("--- Trigger Transfer ---");
        // Transfer tokens out of contract (should trigger fee)
        vm.prank(address(token));
        token.transfer(receiveAddress, 1000 ether);
        
        console.log("--- AFTER-Trigger Transfer ---");
        uint256 contractBalAfter = token.balanceOf(address(token));
        uint256 receiveBalAfter = token.balanceOf(receiveAddress);
        console.log("Contract balance after:", contractBalAfter);
        console.log("ReceiveAddress balance after:", receiveBalAfter);
        
        // Verdict based on contract balance after transfer
        if (contractBalAfter == 100 ether) {
            console.log("Vulnerability not Exist: Fee taken correctly (100 tokens retained)");
        } else if (contractBalAfter > 100 ether) {
            console.log("Vulnerability Exists: Extra fee %s tokens taken beyond 10%%", contractBalAfter - 100 ether);
        } else {
            console.log("Vulnerability Exists: Unexpected contract balance after transfer");
        }
    }
}