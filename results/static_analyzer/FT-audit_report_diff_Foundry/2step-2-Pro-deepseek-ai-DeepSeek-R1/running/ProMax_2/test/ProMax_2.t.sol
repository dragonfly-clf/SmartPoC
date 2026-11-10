// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ProMax.sol";

contract MockWETH {}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x0);
    }
}

contract MockRouter {
    MockFactory public factory;
    address public immutable WETH;

    constructor(address _weth) {
        factory = new MockFactory();
        WETH = _weth;
    }
}

contract MockTarget {
    function transfer(address, uint256) external pure returns (bool) {
        revert("Target function failed");
    }
}

contract FunctionCallTest is Test {
    ProMax token;
    address owner = makeAddr("owner");
    MockTarget target;
    MockRouter router;

    function setUp() public {
        vm.startPrank(owner);
        MockWETH weth = new MockWETH();
        router = new MockRouter(address(weth));
        
        ProMax.FeeWallet memory feeWallet = ProMax.FeeWallet({
            wallet: payable(address(0x01)),
            walletCharity: payable(address(0x02)),
            walletFeeInBNB: false,
            walletCharityFeeInBNB: false
        });
        
        ProMax.Fee memory fee = ProMax.Fee({
            setTaxFee: 0,
            setLiqFee: 0,
            setBurnFee: 0,
            setWalletFee: 0,
            setBuybackFee: 0,
            setWalletCharityFee: 0,
            setRewardFee: 0
        });
        
        address[] memory addrs = new address[](2);
        addrs[0] = address(router);
        addrs[1] = owner; // Payable owner to receive ETH

        token = new ProMax(
            "TestToken",
            "TT",
            18,
            1000000000000000000, // 1 token
            100, // 1% max tx
            100, // 1% max wallet
            feeWallet,
            address(0x05), // Reward token
            1 ether,
            fee,
            addrs
        );
        
        target = new MockTarget();
        vm.deal(owner, 100 ether);
        vm.stopPrank();
    }

    function testRecoverBEP20Failure() public {
        console.log("--- BEFORE-Trigger RecoverBEP20 ---");
        
        console.log("--- Trigger RecoverBEP20 ---");
        vm.prank(owner);
        (bool success, bytes memory returnData) = address(token).call(
            abi.encodeWithSelector(token.recoverBEP20.selector, address(target), 1 ether)
        );
        
        console.log("--- AFTER-Trigger RecoverBEP20 ---");
        string memory finalVerdict;
        if (success) {
            console.log("Call did NOT revert as expected");
            finalVerdict = "Vulnerability Exists: Function should revert on failed transfer but succeeded";
        } else {
            bytes memory expectedRevertData = abi.encodeWithSignature("Error(string)", "Target function failed");
            if (keccak256(returnData) == keccak256(expectedRevertData)) {
                console.log("Call reverted with expected reason: Target function failed");
                finalVerdict = "Vulnerability not Exist: Function correctly reverts on failed transfer";
            } else {
                console.log("Call reverted with UNEXPECTED reason");
                finalVerdict = "Vulnerability Exists: Function reverted but with incorrect error";
            }
        }
        console.log(finalVerdict);
    }
}