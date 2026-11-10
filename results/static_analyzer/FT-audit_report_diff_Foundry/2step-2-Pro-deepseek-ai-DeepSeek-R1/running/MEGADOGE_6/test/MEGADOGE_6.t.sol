// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MEGADOGE.sol";

contract MEGADOGETest is Test {
    MEGADOGE public token;
    address owner = address(0x123);
    address constant ROUTER_ADDRESS = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    bytes4 private constant FACTORY_SELECTOR = bytes4(keccak256("factory()"));
    bytes4 private constant WETH_SELECTOR = bytes4(keccak256("WETH()"));
    bytes4 private constant CREATE_PAIR_SELECTOR = bytes4(keccak256("createPair(address,address)"));

    function setUp() public {
        // Mock router and factory calls
        mockUniswapCalls();
        
        vm.startPrank(owner);
        token = new MEGADOGE();
        vm.stopPrank();
    }

    function test_FeeCanBeSetUnreasonablyHigh() public {
        console.log("--- BEFORE-Trigger DOGERewardsFee ---");
        uint256 initialFee = token.DOGERewardsFee();
        console.log("Initial DOGERewardsFee:", initialFee);

        console.log("--- Trigger setDOGERewardsFee ---");
        // Trigger vulnerability attempt - set fee to unreasonably high 30%
        vm.startPrank(owner);
        token.setDOGERewardsFee(30);  
        vm.stopPrank();
        console.log("Executed setDOGERewardsFee(30)");

        console.log("--- AFTER-Trigger DOGERewardsFee ---");
        uint256 newFee = token.DOGERewardsFee();
        console.log("Current DOGERewardsFee:", newFee);

        // Differential comparison and final verdict
        if (newFee == 30) {
            console.log("Comparison Result: Vulnerability exists - Fee successfully set to 30%");
            console.log("Vulnerability Exists: DOGERewardsFee can be set to unreasonably high value (30%)");
        } else {
            console.log("Comparison Result: Vulnerability does not exist - Fee remains at %s", newFee);
            console.log("Vulnerability not Exist: DOGERewardsFee could not be set to 30%%");
        }
    }

    function mockUniswapCalls() private {
        // Mock router factory call
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(FACTORY_SELECTOR),
            abi.encode(address(0xbeef))
        );
        
        // Mock router WETH call
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(WETH_SELECTOR),
            abi.encode(address(0xeeee))
        );
        
        // Mock factory createPair call
        vm.mockCall(
            address(0xbeef),
            abi.encodeWithSelector(CREATE_PAIR_SELECTOR),
            abi.encode(address(0x0d00))
        );
    }
}