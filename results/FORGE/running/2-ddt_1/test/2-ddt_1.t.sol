// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DiamondDexToken.sol";

contract MockWETH {
    function deposit() external payable {}
    function transfer(address, uint256) external pure returns (bool) {}
    function balanceOf(address) external pure returns (uint256) {}
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xA1B2C3);
    }
}

contract MockRouter {
    address private _factory;
    address private _weth;

    constructor(address factory_, address weth_) {
        _factory = factory_;
        _weth = weth_;
    }

    function factory() external view returns (address) {
        return _factory;
    }

    function WETH() external view returns (address) {
        return _weth;
    }
}

contract DiamondDexFeeTest is Test {
    DiamondDexToken token;
    address owner = address(0x123);
    
    // Create mock dependencies
    MockWETH weth;
    MockFactory factory;
    MockRouter router;

    function setUp() public {
        // Deploy mock chain dependencies
        weth = new MockWETH();
        factory = new MockFactory();
        router = new MockRouter(address(factory), address(weth));

        // Mock Pancake router address
        address mockRouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // Initialize contract at that address
        vm.etch(mockRouterAddress, address(router).code);
        vm.store(mockRouterAddress, bytes32(0), bytes32(abi.encode(address(factory))));
        vm.store(mockRouterAddress, bytes32(uint256(1)), bytes32(abi.encode(address(weth))));
        
        vm.startPrank(owner);
        token = new DiamondDexToken();
        vm.stopPrank();

        // Verify contract initialization
        assertEq(token.owner(), owner, "Owner should be deployer address");
    }

    function testSetHighLiquidityFee() public {
        uint256 feeValue = 30; // Exceeds 25% limit

        console2.log("\n--- BEFORE-Trigger Liquidity Fee ---");
        uint256 preFee = token._liquidityFee();
        console2.log("Pre liquidity fee value: %", preFee);

        console2.log("--- Trigger setLiquidityFeePercent(%u) ---", feeValue);
        vm.prank(owner);
        token.setLiquidityFeePercent(feeValue);

        console2.log("--- AFTER-Trigger Liquidity Fee ---");
        uint256 postFee = token._liquidityFee();
        console2.log("Post liquidity fee value: %", postFee);

        if (postFee > 25) {
            console2.log("Vulnerability Exists: Liquidity fee set beyond 25%% limit (to %%)", postFee);
        } else {
            console2.log("Vulnerability not Exist: Liquidity fee within 25%% limit");
        }
    }

    function testSetHighTaxFee() public {
        uint256 feeValue = 30; // Exceeds 25% limit

        console2.log("\n--- BEFORE-Trigger Tax Fee ---");
        uint256 preFee = token._taxFee();
        console2.log("Pre tax fee value: %", preFee);

        console2.log("--- Trigger setTaxFeePercent(%u) ---", feeValue);
        vm.prank(owner);
        token.setTaxFeePercent(feeValue);

        console2.log("--- AFTER-Trigger Tax Fee ---");
        uint256 postFee = token._taxFee();
        console2.log("Post tax fee value: %", postFee);

        if (postFee > 25) {
            console2.log("Vulnerability Exists: Tax fee set beyond 25%% limit (to %%)", postFee);
        } else {
            console2.log("Vulnerability not Exist: Tax fee within 25%% limit");
        }
    }

    function testSetHighMarketingFee() public {
        uint256 feeValue = 30; // Exceeds 25% limit

        console2.log("\n--- BEFORE-Trigger Marketing Fee ---");
        uint256 preFee = token._MKTshare();
        console2.log("Pre marketing fee value: %", preFee);

        console2.log("--- Trigger setMarketingFeePercent(%u) ---", feeValue);
        vm.prank(owner);
        token.setMarketingFeePercent(feeValue);

        console2.log("--- AFTER-Trigger Marketing Fee ---");
        uint256 postFee = token._MKTshare();
        console2.log("Post marketing fee value: %", postFee);

        if (postFee > 25) {
            console2.log("Vulnerability Exists: Marketing fee set beyond 25%% limit (to %%)", postFee);
        } else {
            console2.log("Vulnerability not Exist: Marketing fee within 25%% limit");
        }
    }
}