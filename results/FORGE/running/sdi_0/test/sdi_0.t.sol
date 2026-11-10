// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SLAMDUNKINU.sol";

// Mock Pancake Router implementation
contract MockPancakeRouter {
    address public immutable factory;
    
    constructor(address _factory) {
        factory = _factory;
    }
    
    function getAmountsOut(uint, address[] calldata) external pure returns (uint[] memory amounts) {
        amounts = new uint[](2);
        amounts[0] = 100000;
        amounts[1] = 100000;
        return amounts;
    }
}

contract MockERC20 {
    mapping(address => uint256) public balanceOf;
    
    function transfer(address to, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

contract MockFactory {
    mapping(address => mapping(address => address)) public getPair;
    
    function createPair(address tokenA, address tokenB) external returns (address pair) {
        pair = address(new MockERC20());
        getPair[tokenA][tokenB] = pair;
        getPair[tokenB][tokenA] = pair;
        return pair;
    }
}

contract StopTransactionTest is Test {
    SLAMDUNKINU token;
    address owner = makeAddr("owner");
    address constant presaler = address(0x0628678CD6542761DB8709bdB61119D65cD0029f);
    address recipient = makeAddr("recipient");
    address constant PANCAKE_ROUTER = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    function setUp() public {
        // Create mock factory
        MockFactory mockFactory = new MockFactory();
        
        // Deploy mock router with correct bytecode
        MockPancakeRouter mockRouter = new MockPancakeRouter(address(mockFactory));
        vm.etch(PANCAKE_ROUTER, address(mockRouter).code);
        
        // Deploy token - constructor already mints initial tokens to presaler
        vm.prank(owner);
        token = new SLAMDUNKINU();
        
        // Get decimals and set swap threshold
        uint256 tokenDecimals = token.decimals();
        uint256 swapThreshold = 10**tokenDecimals;

        // Enable swap back functionality
        vm.prank(owner);
        token.setSwapBackSettings(true, swapThreshold);
        
        // Fund contract with tokens to trigger swapBack later
        uint256 transferAmount = swapThreshold * 2;
        vm.prank(presaler);
        token.transfer(address(token), transferAmount);
    }

    function testSwapBackRevertsWhenFeeZero() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 preBalanceSender = token.balanceOf(presaler);
        uint256 preBalanceRecipient = token.balanceOf(recipient);
        console.log("Sender balance before:", preBalanceSender);
        console.log("Recipient balance before:", preBalanceRecipient);

        console.log("--- Trigger SetZeroFeesAndTransfer ---");
        // Set all fees to 0% - creates vulnerability condition
        vm.prank(owner);
        token.setFees(0, 0, 0, 0, 100);

        // Attempt transfer that should trigger and revert in swapBack
        vm.expectRevert(bytes("SafeMath: division by zero"));
        vm.prank(presaler);
        token.transfer(recipient, 1000);  

        console.log("--- AFTER-Trigger State ---");
        uint256 postBalanceSender = token.balanceOf(presaler);
        uint256 postBalanceRecipient = token.balanceOf(recipient);
        console.log("Sender balance after:", postBalanceSender);
        console.log("Recipient balance after:", postBalanceRecipient);

        // Verify state remains unchanged after reverted transfer
        bool stateUnchanged = (preBalanceSender == postBalanceSender) && 
                             (preBalanceRecipient == postBalanceRecipient);
        console.log("State unchanged:", stateUnchanged);

        // Final vulnerability assessment
        if (stateUnchanged) {
            console.log("Vulnerability Exists: Zero fee configuration causes division-by-zero revert preventing state changes");
        } else {
            console.log("Vulnerability not Exist: Fee change didn't break functionality");
        }
    }
}