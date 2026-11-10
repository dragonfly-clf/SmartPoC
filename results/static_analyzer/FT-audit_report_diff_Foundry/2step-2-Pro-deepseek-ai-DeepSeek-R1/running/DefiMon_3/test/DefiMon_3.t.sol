// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DefiMon.sol";

contract MockERC20 {}

contract MockPancakeFactory {
    address public immutable tokenPair;

    constructor(address _pair) {
        tokenPair = _pair;
    }

    function createPair(address, address) external view returns (address) {
        return tokenPair;
    }
}

contract MockPancakeRouter {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract DefiMonTest is Test {
    DefiMon public token;
    address public owner;
    address public user = address(0x1);
    address public constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        owner = address(this);
        
        address mockPair = address(new MockERC20());
        address mockWETH = address(0xDead);
        MockPancakeFactory mockFactory = new MockPancakeFactory(mockPair);
        MockPancakeRouter mockRouter = new MockPancakeRouter(address(mockFactory), mockWETH);
        
        vm.etch(PANCAKE_ROUTER, address(mockRouter).code);
        token = new DefiMon();
        
        token.excludeFromFee(user, true);
        token.enableTrading();
        token.transfer(user, 1000 ether);
    }

    function testTransferZeroAddressReverts() public {
        // Record initial state
        console.log("\n--- BEFORE-Trigger Transfer ---");
        uint256 initUserBalance = token.balanceOf(user);
        uint256 initZeroBalance = token.balanceOf(address(0));
        console.log("User initial balance: %s", initUserBalance);
        console.log("Zero address initial balance: %s", initZeroBalance);

        // Execute the transfer operation
        console.log("--- Trigger Transfer: Zero Address ---");
        vm.startPrank(user);
        vm.expectRevert("ERC20: transfer to the zero address");
        token.transfer(address(0), 100 ether);
        vm.stopPrank();

        // Record post-execution state
        console.log("--- AFTER-Trigger Transfer ---");
        uint256 finalUserBalance = token.balanceOf(user);
        uint256 finalZeroBalance = token.balanceOf(address(0));
        console.log("User final balance: %s", finalUserBalance);
        console.log("Zero address final balance: %s", finalZeroBalance);

        // Validate state preservation
        bool userBalanceUnchanged = initUserBalance == finalUserBalance;
        bool zeroBalanceUnchanged = initZeroBalance == finalZeroBalance;
        bool statePreserved = userBalanceUnchanged && zeroBalanceUnchanged;

        // Final vulnerability verdict
        if (statePreserved) {
            console.log("Vulnerability not Exist: State unchanged after reverting operation");
        } else {
            console.log("Vulnerability Exists: Unauthorized state change detected");
        }
    }
}