// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TEGPAY.sol";

contract TEGPAYTest is Test {
    TEGPAY public token;
    address constant OWNER = 0xBd51b6D98574327734C1621A7283778c5e6Af86e;
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Create mock addresses
        address factoryAddr = address(0xFa1);
        address wethAddr = address(0x20);
        address pairAddr = address(0x30);

        // Mock router factory() call
        vm.mockCall(
            ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(factoryAddr)
        );
        
        // Mock router WETH() call
        vm.mockCall(
            ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(wethAddr)
        );
        
        // Mock factory createPair() call
        vm.mockCall(
            factoryAddr,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(pairAddr)
        );

        // Deploy token after setting up mocks
        token = new TEGPAY();
    }

    function testDevelopmentFeeCanExceed25Percent() public {
        console.log("--- BEFORE-Trigger _developmentFee ---");
        uint256 initialDevFee = token._developmentFee();
        console.log("Initial development fee:", initialDevFee, "%");

        console.log("--- Trigger: setDevelopmentFeePercent(26) ---");
        vm.startPrank(OWNER);
        token.setDevelopmentFeePercent(26);
        vm.stopPrank();

        console.log("--- AFTER-Trigger _developmentFee ---");
        uint256 newDevFee = token._developmentFee();
        console.log("New development fee:", newDevFee, "%");

        if (newDevFee == 26) {
            console.log("Vulnerability Exists: _developmentFee was set to 26% (exceeding 25% cap)");
        } else {
            console.log("Vulnerability not Exist: _developmentFee remains at %s%% (not changed to 26%%)", newDevFee);
        }
    }
}