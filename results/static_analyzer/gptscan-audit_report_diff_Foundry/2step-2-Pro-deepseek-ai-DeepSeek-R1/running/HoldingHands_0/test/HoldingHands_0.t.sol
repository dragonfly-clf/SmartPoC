// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/HoldingHands.sol";

contract CallbackRouter {
    event AddLiquidityETH(uint amountTokenDesired, uint amountTokenMin, uint amountETHMin);

    receive() external payable {}
    
    function factory() external view returns (address) {
        return address(this);
    }

    function WETH() external pure returns (address) {
        return address(0x222);
    }

    function createPair(address, address) external pure returns (address) {
        return address(0x333);
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint, 
        uint, 
        address[] calldata, 
        address to,
        uint 
    ) external {
        payable(to).transfer(1);
    }

    function addLiquidityETH(
        address, 
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address, 
        uint 
    ) external payable returns (uint, uint, uint) {
        emit AddLiquidityETH(amountTokenDesired, amountTokenMin, amountETHMin);
        return (0,0,0);
    }
}

contract HoldingHandsTest is Test {
    HoldingHands public token;
    address constant REAL_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        CallbackRouter cbrouter = new CallbackRouter();
        vm.etch(REAL_ROUTER, address(cbrouter).code);
        vm.deal(REAL_ROUTER, 1 ether);

        token = new HoldingHands();
        token.setSwapAndLiquifyEnabled(true);

        uint256 ts = token.totalSupply();
        token.transfer(address(token), ts * 99 / 100);
    }

    function test_SlippageProtectionMissing() public {
        console.log("--- BEFORE-Trigger: Normal operation state ---");
        
        console.log("--- Trigger: Transfer that should activate fee processing ---");
        vm.recordLogs();
        token.transfer(address(0xdead), 1);
        Vm.Log[] memory logs = vm.getRecordedLogs();
        
        console.log("--- AFTER-Trigger: Analyzing emitted events ---");
        bytes32 sig = keccak256("AddLiquidityETH(uint256,uint256,uint256)");
        uint256 actualMinToken = type(uint256).max; // Initialize with high value
        for (uint i; i < logs.length; i++) {
            if (logs[i].emitter == REAL_ROUTER && logs[i].topics[0] == sig) {
                (, actualMinToken, ) = abi.decode(logs[i].data, (uint, uint, uint));
                console.log("Actual minToken value from AddLiquidityETH event:", actualMinToken);
                break;
            }
        }

        console.log("--- VERDICT: Slippage Protection Validation ---");
        if(actualMinToken == type(uint256).max) {
            console.log("Vulnerability not Exist: AddLiquidityETH event was never emitted");
        } else if (actualMinToken == 0) {
            console.log("Vulnerability Exists: Token slippage protection missing (minToken set to 0)");
        } else {
            console.log("Vulnerability not Exist: minToken > 0 shows slippage protection active");
        }
    }
}