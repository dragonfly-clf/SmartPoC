// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/moonship.sol";

contract LowLevelCallTest is Test {
    MoonShip token;
    MockRouter mockRouter;
    address constant EOASender = address(0x1111);
    address constant EOAReceiver = address(0x9999);

    function setUp() public {
        // Deploy updated mock router with properly implemented factory
        mockRouter = new MockRouter();
        token = new MoonShip(payable(address(mockRouter)));
        
        // Fund the sender with ETH and tokens for the test
        vm.deal(EOASender, 1 ether);
        uint256 amount = 100e18;
        token.transfer(EOASender, amount);
    }

    function testDisruptiveTransferToEOA() public {
        // Record initial balances
        uint256 senderBalanceBefore = token.balanceOf(EOASender);
        uint256 receiverBalanceBefore = token.balanceOf(EOAReceiver);
        console.log("--- BEFORE-Trigger Transfer ---");
        console.log("Sender balance:", senderBalanceBefore);
        console.log("Receiver balance:", receiverBalanceBefore);
        
        console.log("--- Trigger DisruptiveTransfer ---");
        vm.prank(EOASender);
        token.disruptiveTransfer{value: 0.001 ether}(EOAReceiver, 100e18);
        
        // Record final balances
        uint256 senderBalanceAfter = token.balanceOf(EOASender);
        uint256 receiverBalanceAfter = token.balanceOf(EOAReceiver);
        console.log("--- AFTER-Trigger Transfer ---");
        console.log("Sender balance:", senderBalanceAfter);
        console.log("Receiver balance:", receiverBalanceAfter);
        
        // Calculate balance changes
        uint256 senderLoss = senderBalanceBefore - senderBalanceAfter;
        uint256 receiverGain = receiverBalanceAfter - receiverBalanceBefore;
        bool fundsTransferred = senderLoss == 100e18 && receiverGain == 100e18;
        console.log("Amount transferred (based on sender loss):", senderLoss);
        console.log("Amount transferred (based on receiver gain):", receiverGain);

        // Final verdict
        if (fundsTransferred) {
            console.log("Vulnerability Exists: The tokens were successfully transferred as expected");
        } else {
            console.log("Vulnerability not Exist: The token transfers were not processed correctly");
        }
    }
}

contract MockRouter {
    MockFactory public factoryContract;
    address public immutable WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    constructor() public {
        factoryContract = new MockFactory();
    }
    
    function factory() external view returns (address) {
        return address(factoryContract);
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        // Return dummy non-zero contract address
        return address(0x123);
    }
}