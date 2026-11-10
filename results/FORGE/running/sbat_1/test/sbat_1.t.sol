// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SINCEREBAT.sol";

contract SINCEREBATTest is Test {
    // Fixed router address used in contract constructor
    address constant ROUTER_ADRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address mockFactory = address(0xABCD);
    address mockWETH = address(0x1);
    address mockPair = address(0x2);

    SINCEREBAT token;
    address deployer = address(0x1);
    address sender = address(0x3);
    address receiver = address(0x4);
    uint256 constant TEST_AMOUNT = 10**18; // 1 token with 18 decimals

    function setUp() public {
        vm.startPrank(deployer);
        
        // Mock Uniswap router/factory calls
        vm.mockCall(
            ROUTER_ADRESS,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            ROUTER_ADRESS,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );

        // Deploy token contract
        token = new SINCEREBAT();
        
        // Provide test tokens to sender with sufficient amount
        token.transfer(sender, 1000 * TEST_AMOUNT);
        vm.stopPrank();
    }

    function testFeeManipulationVulnerability() public {
        console.log("=== BEFORE fee manipulation ===");
        (uint256 txFeeBefore, uint256 receivedAmountBefore, bool successBefore) = _executeTransferAndCalcFee();
        require(successBefore, "Initial transfer must succeed");
        uint256 feePercentBefore = (txFeeBefore * 100) / TEST_AMOUNT;
        console.log("Initial tax fee(%):", feePercentBefore);
        console.log("Receiver received:", receivedAmountBefore);

        console.log("=== MANIPULATION: Set tax fee to 99% ===");
        vm.prank(deployer);
        token.setTaxFeePercent(99);

        console.log("=== AFTER fee manipulation ===");
        (uint256 txFeeAfter, uint256 receivedAmountAfter, bool successAfter) = _executeTransferAndCalcFee();
        
        // Final verification and verdict
        if (successAfter) {
            uint256 feePercentAfter = (txFeeAfter * 100) / TEST_AMOUNT;
            console.log("Manipulated tax fee(%):", feePercentAfter);
            console.log("Receiver received:", receivedAmountAfter);
            
            if (feePercentAfter >= 99) {
                console.log("Vulnerability Exists: Successfully set tax fee to 99% without transaction revert");
            } else {
                console.log("Vulnerability not Exist: Tax fee remains within acceptable limits despite exploit attempt");
            }
        } else {
            console.log("Transfer reverted after tax fee manipulation");
            console.log("Vulnerability Exists: Setting tax fee to 99% causes transfer failure");
        }
    }

    function _executeTransferAndCalcFee() private returns (
        uint256 feeAmount,
        uint256 receivedAmount,
        bool success
    ) {
        uint256 receiverBalBefore = token.balanceOf(receiver);
        vm.startPrank(sender);
        (bool transferSuccess, ) = address(token).call(
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                receiver,
                TEST_AMOUNT
            )
        );
        vm.stopPrank();
        
        if (transferSuccess) {
            uint256 receiverBalAfter = token.balanceOf(receiver);
            receivedAmount = receiverBalAfter - receiverBalBefore;
            feeAmount = TEST_AMOUNT - receivedAmount;
            return (feeAmount, receivedAmount, true);
        }
        return (0, 0, false);
    }
}