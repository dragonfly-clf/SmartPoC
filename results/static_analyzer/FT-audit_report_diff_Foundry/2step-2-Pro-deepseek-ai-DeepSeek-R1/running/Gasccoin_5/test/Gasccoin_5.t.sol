// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Gasccoin.sol";

contract GasccoinTest is Test {
    Gasccoin token;
    address owner = makeAddr("owner");
    address mockDev = makeAddr("dev");
    address mockMarketing = makeAddr("marketing");
    address constant mockRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address mockFactory = makeAddr("factory");
    address mockWETH = makeAddr("weth");
    address mockPair = makeAddr("pair");

    function setUp() public {
        // Precompute token creation address
        uint256 nonce = vm.getNonce(owner);
        address tokenAddress = vm.computeCreateAddress(owner, nonce);

        // Mock router factory call
        vm.mockCall(
            mockRouter,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        
        // Mock router WETH call
        vm.mockCall(
            mockRouter,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Mock factory createPair with correct arguments
        bytes4 createPairSelector = bytes4(keccak256("createPair(address,address)"));
        vm.mockCall(
            mockFactory,
            abi.encodeWithSelector(
                createPairSelector,
                tokenAddress,
                mockWETH
            ),
            abi.encode(mockPair)
        );

        // Deploy token
        vm.startPrank(owner);
        token = new Gasccoin();
        vm.stopPrank();
        
        // Setup initial addresses
        vm.startPrank(owner);
        token.setNewDevAddress(payable(mockDev));
        token.setNewMarketingAddress(payable(mockMarketing));
        vm.stopPrank();
    }

    function testManualSendLockedWhenAddressZero() public {
        // Set dev/marketing addresses to zero
        vm.startPrank(owner);
        token.setNewDevAddress(payable(address(0)));
        token.setNewMarketingAddress(payable(address(0)));
        vm.stopPrank();

        // Fund contract with ETH
        uint256 ethAmount = 1 ether;
        deal(address(token), ethAmount);

        // Record state BEFORE
        console.log("--- BEFORE-Trigger Balance ---");
        uint256 contractBalanceBefore = address(token).balance;
        uint256 zeroBalanceBefore = address(0).balance;
        console.log("Contract ETH before:", contractBalanceBefore);
        console.log("Zero addr ETH before:", zeroBalanceBefore);

        console.log("--- Trigger ManualSend ---");
        // Execute vulnerable function
        vm.prank(owner);
        token.manualsend();

        // Record state AFTER
        console.log("--- AFTER-Trigger Balance ---");
        uint256 contractBalanceAfter = address(token).balance;
        uint256 zeroBalanceAfter = address(0).balance;
        console.log("Contract ETH after:", contractBalanceAfter);
        console.log("Zero addr ETH after:", zeroBalanceAfter);

        // Validate vulnerability
        bool ethBurnedCorrectly = contractBalanceAfter == 0 &&
            zeroBalanceAfter == zeroBalanceBefore + ethAmount;

        if (ethBurnedCorrectly) {
            console.log("Vulnerability not Exist: ETH burned correctly showing no lock");
        } else {
            console.log("Vulnerability Exists: ETH not burned (incorrect transfer behavior)");
        }
    }
}