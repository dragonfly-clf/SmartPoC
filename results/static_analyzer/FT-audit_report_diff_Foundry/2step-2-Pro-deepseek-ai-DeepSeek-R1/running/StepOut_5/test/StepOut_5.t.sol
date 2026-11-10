// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/StepOut.sol";

// Mock router implementation
contract MockRouter {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

// Mock factory implementation
contract MockFactory {
    function createPair(address, address) external pure returns (address pair) {
        return address(0x456);
    }
}

contract StepOutTransferTest is Test {
    StepOut public token;
    address public owner = makeAddr("owner");
    address public userA = makeAddr("userA");
    address public userB = makeAddr("userB");
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;

    // Mock addresses
    MockRouter public mockRouter;
    address immutable mockFactory = address(new MockFactory());
    address immutable mockWeth = address(0x789);

    function setUp() public {
        // Deploy mock router with mock factory and WETH
        mockRouter = new MockRouter(mockFactory, mockWeth);

        // Change hardcoded router address to our mock router
        vm.etch(0x10ED43C718714eb63d5aA57B78B54704E256024E, address(mockRouter).code);

        vm.startPrank(owner);
        // Deploy token contract - will now use our mock system
        token = new StepOut();
        // Configure fees
        token.setTaxes(50, 0, 50);
        token.setSwapEnabled(false);
        
        // Transfer initial tokens to userA
        uint256 amount = 100 * 10 ** token.decimals();
        token.transfer(userA, amount);
        vm.stopPrank();
    }

    function test_RevertOnZeroDirectTransfer() public {
        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 balanceA_before = token.balanceOf(userA);
        uint256 balanceB_before = token.balanceOf(userB);
        console.log("UserA balance: %d, UserB balance: %d", balanceA_before, balanceB_before);

        console.log("--- Trigger Transfer (0 amount) ---");
        vm.prank(userA);
        (bool success, ) = address(token).call(abi.encodeWithSignature("transfer(address,uint256)", userB, 0));

        console.log("--- AFTER-Trigger Transfer ---");
        uint256 balanceA_after = token.balanceOf(userA);
        uint256 balanceB_after = token.balanceOf(userB);
        console.log("UserA balance: %d, UserB balance: %d", balanceA_after, balanceB_after);

        if (success) {
            console.log("Vulnerability Exists: contract allows zero-value transfers");
            fail();
        } else {
            console.log("Vulnerability not Exist: zero-value transfers revert as expected");
        }
    }

    function test_RevertOnZeroTransferFrom() public {
        uint256 amount = 100 * 10 ** token.decimals();
        // Approve test contract to spend tokens
        vm.prank(userA);
        token.approve(address(this), amount);

        console.log("--- BEFORE-Trigger TransferFrom ---");
        uint256 balanceA_before = token.balanceOf(userA);
        uint256 balanceB_before = token.balanceOf(userB);
        console.log("UserA balance: %d, UserB balance: %d", balanceA_before, balanceB_before);

        console.log("--- Trigger TransferFrom (0 amount) ---");
        (bool success, ) = address(token).call(abi.encodeWithSignature("transferFrom(address,address,uint256)", userA, userB, 0));

        console.log("--- AFTER-Trigger TransferFrom ---");
        uint256 balanceA_after = token.balanceOf(userA);
        uint256 balanceB_after = token.balanceOf(userB);
        console.log("UserA balance: %d, UserB balance: %d", balanceA_after, balanceB_after);

        if (success) {
            console.log("Vulnerability Exists: contract allows zero-value transferFrom");
            fail();
        } else {
            console.log("Vulnerability not Exist: zero-value transferFrom reverts as expected");
        }
    }
}