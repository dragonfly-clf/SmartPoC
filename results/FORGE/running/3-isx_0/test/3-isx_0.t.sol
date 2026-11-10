// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ProMax.sol";

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0xdead);
    }
}

contract MockRouter {
    address public factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract FeeManipulationTest is Test {
    ProMax token;
    address owner;
    address constant dummyWETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    function setUp() public {
        // Create a labeled owner and fund it
        owner = makeAddr("owner");
        vm.deal(owner, 100 ether);

        // Deploy mock contracts
        MockFactory factory = new MockFactory();
        MockRouter router = new MockRouter(address(factory), dummyWETH);
        
        // Prepare token parameters (explicit payable casting)
        ProMax.FeeWallet memory wallet = ProMax.FeeWallet({
            wallet: payable(address(0x123)),
            walletCharity: payable(address(0x456)),
            walletFeeInBNB: false,
            walletCharityFeeInBNB: false
        });
        
        address _rewardToken = address(0);
        uint256 _minimumTokenBalance = 0;
        ProMax.Fee memory fee = ProMax.Fee(0,0,0,0,0,0,0);
        address[] memory addrs = new address[](2);
        addrs[0] = address(router);
        addrs[1] = owner;

        // Deploy token as owner
        vm.startPrank(owner);
        token = new ProMax{value: 1 ether}(
            "TestToken",
            "TEST",
            18,
            1000000 * 10 ** 18,
            10000,  // maxTxPercent
            10000,  // maxWalletPercent
            wallet,
            _rewardToken,
            _minimumTokenBalance,
            fee,
            addrs
        );
        vm.stopPrank();
    }

    function test_FeeManipulationBeyond25Pct() public {
        console.log("--- BEFORE-Trigger Fee Query ---");
        uint256[7] memory feesBefore = [
            uint256(token._taxFee()),
            uint256(token._liquidityFee()),
            uint256(token._burnFee()),
            uint256(token._walletFee()),
            uint256(token._buybackFee()),
            uint256(token._walletCharityFee()),
            uint256(token._rewardFee())
        ];
        uint256 totalBefore = feesBefore[0] + feesBefore[1] + feesBefore[2] +
                             feesBefore[3] + feesBefore[4] + feesBefore[5];
        
        console.log("Initial Tax Fee: ", feesBefore[0]);
        console.log("Initial Liquidity Fee: ", feesBefore[1]);
        console.log("Initial Burn Fee: ", feesBefore[2]);
        console.log("Initial Wallet Fee: ", feesBefore[3]);
        console.log("Initial Buyback Fee: ", feesBefore[4]);
        console.log("Initial Charity Fee: ", feesBefore[5]);
        console.log("Initial Reward Fee: ", feesBefore[6]);
        console.log("Initial Total Fees: ", totalBefore);

        console.log("--- Trigger Fee Change ---");
        bool success;
        vm.prank(owner);
        try token.setAllFeePercent(10,10,10,10,10,10,0) {
            success = true;
        } catch {
            success = false;
        }

        console.log("--- AFTER-Trigger Fee Query ---");
        uint256[7] memory feesAfter = [
            uint256(token._taxFee()),
            uint256(token._liquidityFee()),
            uint256(token._burnFee()),
            uint256(token._walletFee()),
            uint256(token._buybackFee()),
            uint256(token._walletCharityFee()),
            uint256(token._rewardFee())
        ];
        uint256 totalAfter = feesAfter[0] + feesAfter[1] + feesAfter[2] + 
                            feesAfter[3] + feesAfter[4] + feesAfter[5];
            
        console.log("Tax Fee After: ", feesAfter[0]);
        console.log("Liquidity Fee After: ", feesAfter[1]);
        console.log("Burn Fee After: ", feesAfter[2]);
        console.log("Wallet Fee After: ", feesAfter[3]);
        console.log("Buyback Fee After: ", feesAfter[4]);
        console.log("Charity Fee After: ", feesAfter[5]);
        console.log("Reward Fee After: ", feesAfter[6]);
        console.log("Total Fees After: ", totalAfter);

        // Final verdict determination
        if (success && totalAfter > 25) {
            console.log("Vulnerability Exists: Total fees exceeded 25%% (Actual=%d%%)", totalAfter);
        } else if (success) {
            console.log("Vulnerability not Exist: Total fees within 25%% limit (Actual=%d%%)", totalAfter);
        } else {
            console.log("Vulnerability not Exist: Function reverted preventing fee overflow");
        }
    }
}