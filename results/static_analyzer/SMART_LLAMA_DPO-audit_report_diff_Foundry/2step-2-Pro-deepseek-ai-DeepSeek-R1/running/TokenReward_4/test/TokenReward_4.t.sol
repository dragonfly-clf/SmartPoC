// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/TokenReward.sol";

contract MockPinkAntiBot {
    function setTokenOwner(address) external {}
}

contract TokenRewardPrivilegeTest is Test {
    TokenReward token;
    address constant OWNER = 0x8b4145a7a3c381E30de988F19D6958b4dA7aBD79;

    function setUp() public {
        // 1. Mock PinkAntiBot
        address pinkAddr = 0x8EFDb3b642eb2a20607ffe0A56CFefF6a95Df002;
        MockPinkAntiBot pinkMock = new MockPinkAntiBot();
        vm.etch(pinkAddr, address(pinkMock).code);
        
        // 2. Mock Pancake Router
        address routerAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address mockFactory = address(0x5678);
        address mockPair = address(0x9abc);
        
        // Mock router.factory() to return mockFactory
        vm.mockCall(
            routerAddr,
            abi.encodeWithSelector(bytes4(keccak256("factory()"))),
            abi.encode(mockFactory)
        );
        
        // Mock router.WETH() to return dummy address
        vm.mockCall(
            routerAddr,
            abi.encodeWithSelector(bytes4(keccak256("WETH()"))),
            abi.encode(address(0x123))
        );
        
        // Mock factory.createPair to return mockPair
        vm.mockCall(
            mockFactory,
            abi.encodeWithSelector(bytes4(keccak256("createPair(address,address)"))),
            abi.encode(mockPair)
        );

        // Deploy token contract
        token = new TokenReward();
    }

    function testSetRewardYieldWithoutValidation() public {
        console2.log("--- BEFORE-TRIGGER: testSetRewardYieldWithoutValidation ---");
        uint256 yieldBefore = token.rewardYield();
        uint256 denomBefore = token.rewardYieldDenominator();
        console2.log("Before: rewardYield =", yieldBefore);
        console2.log("Before: rewardYieldDenominator =", denomBefore);
        
        console2.log("--- TRIGGER: Setting yield to 1e6% and then to 0 ---");
        vm.startPrank(OWNER);
        token.setRewardYield(1_000_000, 1);
        token.setRewardYield(0, 0);
        vm.stopPrank();
        
        console2.log("--- AFTER-TRIGGER: testSetRewardYieldWithoutValidation ---");
        uint256 yieldAfter = token.rewardYield();
        uint256 denomAfter = token.rewardYieldDenominator();
        console2.log("After: rewardYield =", yieldAfter);
        console2.log("After: rewardYieldDenominator =", denomAfter);
        
        if (denomAfter == 0 && yieldAfter == 0) {
            console2.log("Vulnerability Exists: division by zero risk detected (validated)");
        } else {
            console2.log("Vulnerability not Exist: Safe denominator value detected");
        }
    }

    function testSetRebaseFrequencyWithoutValidation() public {
        console2.log("--- BEFORE-TRIGGER: testSetRebaseFrequencyWithoutValidation ---");
        uint256 freqBefore = token.rebaseFrequency();
        console2.log("Before: rebaseFrequency =", freqBefore);
        
        console2.log("--- TRIGGER: Setting rebaseFrequency to 0/1/1e6 ---");
        vm.startPrank(OWNER);
        token.setRebaseFrequency(0);
        token.setRebaseFrequency(1);
        token.setRebaseFrequency(1_000_000);
        vm.stopPrank();
        
        console2.log("--- AFTER-TRIGGER: testSetRebaseFrequencyWithoutValidation ---");
        uint256 freqAfter = token.rebaseFrequency();
        console2.log("After: rebaseFrequency =", freqAfter);
        
        if (freqAfter == 1_000_000) {
            console2.log("Vulnerability Exists: contract accepts impractical rebase value (validated)");
        } else {
            console2.log("Vulnerability not Exist: rebaseFrequency validation exists");
        }
    }

    function testSetTargetLiquidityWithoutValidation() public {
        console2.log("--- BEFORE-TRIGGER: No state available ---");
        bool setSuccess = true;
        
        console2.log("--- TRIGGER: Setting invalid liquidity values ---");
        vm.startPrank(OWNER);
        try token.setTargetLiquidity(0, 0) {
            console2.log("Set (0,0) success");
        } catch {
            setSuccess = false;
        }
        try token.setTargetLiquidity(1_000_000, 1) {
            console2.log("Set (1e6,1) success");
        } catch {
            setSuccess = false;
        }
        try token.setTargetLiquidity(0, 1_000_000) {
            console2.log("Set (0,1e6) success");
        } catch {
            setSuccess = false;
        }
        vm.stopPrank();
        
        if (setSuccess) {
            console2.log("Vulnerability Exists: contract accepts all invalid liquidity settings (validated)");
        } else {
            console2.log("Vulnerability not Exist: liquidity validation exists");
        }
    }

    function testSetMaxFeesWithoutValidation() public {
        console2.log("--- BEFORE-TRIGGER: testSetMaxFeesWithoutValidation ---");
        uint256 liqFeeBefore = token.liquidityFee();
        uint256 treFeeBefore = token.treasuryFee();
        uint256 fireFeeBefore = token.firePitFee();
        uint256 riskFeeBefore = token.riskFreeValueFee();
        uint256 totalFeeBefore = token.totalFee();
        console2.log("Before: liqFee =", liqFeeBefore);
        console2.log("Before: treasuryFee =", treFeeBefore);
        console2.log("Before: firePitFee =", fireFeeBefore);
        console2.log("Before: riskFee =", riskFeeBefore);
        console2.log("Before: totalFee =", totalFeeBefore);
        
        console2.log("--- TRIGGER: Setting dangerous fee values (251/1000) ---");
        vm.startPrank(OWNER);
        token.setFees(
            51,            // liquidityFee (incr by 1 to make total unsafe)
            60,             // treasuryFee
            1000,          // feeDenominator
            40,             // firePitFee
            0,              // sellFeel 
            0,              // sellFeet
            0,              // sellFeef
            100             // riskFreeValueFee 
        );
        vm.stopPrank();
        
        console2.log("--- AFTER-TRIGGER: testSetMaxFeesWithoutValidation ---");
        uint256 liqFeeAfter = token.liquidityFee();
        uint256 treFeeAfter = token.treasuryFee();
        uint256 fireFeeAfter = token.firePitFee();
        uint256 riskFeeAfter = token.riskFreeValueFee();
        uint256 totalFeeAfter = token.totalFee();
        console2.log("After: liqFee =", liqFeeAfter);
        console2.log("After: treasuryFee =", treFeeAfter);
        console2.log("After: firePitFee =", fireFeeAfter);
        console2.log("After: riskFee =", riskFeeAfter);
        console2.log("After: totalFee =", totalFeeAfter);
        
        if (totalFeeAfter == (51+60+40+100)) { // 251 total = 25.1%
            console2.log("Vulnerability Exists: accumulated dangerous fee values (validated)");
        } else {
            console2.log("Vulnerability not Exist: fee changes blocked");
        }
    }
}