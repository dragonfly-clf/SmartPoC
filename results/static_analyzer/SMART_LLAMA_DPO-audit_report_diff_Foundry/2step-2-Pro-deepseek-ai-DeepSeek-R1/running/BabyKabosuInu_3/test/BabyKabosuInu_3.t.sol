// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BabyKabosuInu.sol";

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0xFaC70);
    }

    function WETH() external pure returns (address) {
        return address(0xBeEf);
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint, /* amountIn */
        uint, /* amountOutMin */
        address[] calldata, /* path */
        address, /* to */
        uint /* deadline */
    ) external pure {
        return;
    }

    function addLiquidityETH(
        address, /* token */
        uint, /* amountTokenDesired */
        uint, /* amountTokenMin */
        uint, /* amountETHMin */
        address, /* to */
        uint /* deadline */
    ) external payable returns (uint, uint, uint) {
        return (1, 1, 1);
    }
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0x1234);
    }
}

contract BabyKabosuInuTest is Test {
    BabyKabosuInu token;
    address owner;
    address whale = address(0x8521);
    address pair = address(0x1234);
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Setup mock router
        MockRouter mockRouter = new MockRouter();
        vm.etch(routerAddress, address(mockRouter).code);
        
        // Setup mock factory
        address factoryAddr = address(0xFaC70);
        MockFactory mockFactory = new MockFactory();
        vm.etch(factoryAddr, address(mockFactory).code);

        owner = address(this);
        
        // Deploy token contract
        token = new BabyKabosuInu();
        
        // Configure token
        token.setTrading(true);
        token.setMinTokensBeforeSwap(0);
        token.setSwapAndLiquifyEnabled(true);
        
        // Prepare whale account
        uint256 totalSupply = token.totalSupply();
        uint256 whaleFund = totalSupply / 10;
        token.transfer(whale, whaleFund);
        
        // Configure addresses
        token.setWalletAddress(owner, owner, owner);
        token.setTaxless(whale, false);
    }

    function test_MissingTransferEventsOnSwap() public {
        console.log("--- BEFORE-Trigger: Initial Setup ---");
        console.log("No state changes required, preparing event test...");
        
        console.log("--- Trigger: Start Transfer Execution ---");
        // Record emitted events
        vm.recordLogs();
        
        // Trigger swap operation by selling tokens (transfer to pair)
        vm.startPrank(whale);
        token.transfer(pair, 1 ether);
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger: Analyze Event Logs ---");
        // Verify no internal transfer events were emitted
        bool foundInternalTransfer = false;
        Vm.Log[] memory logs = vm.getRecordedLogs();
        
        for (uint i = 0; i < logs.length; i++) {
            if (logs[i].topics[0] == keccak256("Transfer(address,address,uint256)")) {
                address from = address(uint160(uint256(logs[i].topics[1])));
                if (from == address(token)) {
                    foundInternalTransfer = true;
                    console.log("Unexpected Transfer event found from contract");
                    break;
                }
            }
        }
        
        // Print vulnerability verdict
        if (foundInternalTransfer) {
            console.log("Vulnerability not Exist: Required Transfer events present during swap");
        } else {
            console.log("Vulnerability Exists: Missing required Transfer events during swap operations");
        }
        
        // Keep original test assertion
        assertFalse(foundInternalTransfer, "Transfer events detected during swap operations");
    }
}