// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external returns (address) {
        return address(0x222);
    }
}

contract MockUniswapV2Router {
    address public factory;
    address public immutable WETH;

    constructor(address _factory) public {
        factory = _factory;
        WETH = address(0x111);
    }
}

contract CoinTokenFeeManipulationTest is Test {
    CoinToken public token;
    MockUniswapV2Factory public factory;
    MockUniswapV2Router public router;
    address owner = address(0x123);

    function setUp() public {
        factory = new MockUniswapV2Factory();
        router = new MockUniswapV2Router(address(factory));

        token = new CoinToken(
            "TestToken", 
            "TT", 
            18, 
            1000000,  // _supply
            1,        // _txFee
            1,        // _lpFee
            1000000 * 1e18,  // _MAXAMOUNT
            500000 * 1e18,   // SELLMAXAMOUNT
            address(router), 
            owner
        );
    }

    function test_OwnerCanSetFeesBeyond25Percent() public {
        console.log("--- BEFORE Trigger: Fee State ---");
        // 查询初始手续费状态
        uint256 taxFeeBefore = token._taxFee();
        uint256 liquidityFeeBefore = token._liquidityFee();
        console.log("Initial Tax Fee:", taxFeeBefore);
        console.log("Initial Liquidity Fee:", liquidityFeeBefore);

        console.log("--- Trigger: Set Fee to 30% ---");
        // 攻击操作：设置超过25%的手续费
        vm.startPrank(owner);
        token.setTaxFeePercent(30);  // 30% tax fee
        token.setLiquidityFeePercent(30);  // 30% liquidity fee
        vm.stopPrank();

        console.log("--- AFTER Trigger: Fee State ---");
        // 查询修改后手续费状态
        uint256 taxFeeAfter = token._taxFee();
        uint256 liquidityFeeAfter = token._liquidityFee();
        console.log("Tax Fee After Attack:", taxFeeAfter);
        console.log("Liquidity Fee After Attack:", liquidityFeeAfter);

        // 验证漏洞是否存在（手续费是否超过25%）
        if(taxFeeAfter == 30 && liquidityFeeAfter == 30) {
            console.log("Vulnerability Exists: Owner set fees to 30% which exceeds the 25% limit");
        } else {
            console.log("Vulnerability not Exist: Fees are within the 25% limit");
        }
    }
}