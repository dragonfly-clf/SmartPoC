// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Nabana.sol";
import "../src/Nabana.sol";

contract NabanaTest is Test {
    Nabana public nabana;
    address constant VESTING = address(0x123);
    address public userA = address(0x1);
    address public userB = address(0x2);
    uint256 public constant TRANSFER_AMOUNT = 100 * 1e18;

    function setUp() public {
        // Deploy with mock Uniswap setup
        address mockRouter = deployMockRouter();
        vm.etch(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), mockRouter.code);

        // Deploy contract
        nabana = new Nabana(VESTING);
    }

    function deployMockRouter() public returns (address) {
        // Mock contracts to bypass Uniswap initialization
        MockRouter router = new MockRouter(address(new MockFactory()));
        return address(router);
    }

    function testTransferFeesNotApplied() public {
        // Transfer initial tokens to userA from excluded vesting account
        vm.prank(VESTING);
        nabana.transfer(userA, TRANSFER_AMOUNT);

        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 userABalanceBefore = nabana.balanceOf(userA);
        uint256 userBBalanceBefore = nabana.balanceOf(userB);
        uint256 feeWalletBalanceBefore = nabana.balanceOf(nabana.feeWallet());
        
        console.log("UserA balance before:", userABalanceBefore);
        console.log("UserB balance before:", userBBalanceBefore);
        console.log("FeeWallet balance before:", feeWalletBalanceBefore);

        console.log("--- Trigger Transfer ---");
        // Perform test transfer (should apply fees but doesn't)
        vm.prank(userA);
        nabana.transfer(userB, TRANSFER_AMOUNT);
        console.log("Transfer executed from UserA to UserB");

        console.log("--- AFTER-Trigger Transfer ---");
        uint256 userABalanceAfter = nabana.balanceOf(userA);
        uint256 userBBalanceAfter = nabana.balanceOf(userB);
        uint256 feeWalletBalanceAfter = nabana.balanceOf(nabana.feeWallet());
        
        console.log("UserA balance after:", userABalanceAfter);
        console.log("UserB balance after:", userBBalanceAfter);
        console.log("FeeWallet balance after:", feeWalletBalanceAfter);

        // Compute balance changes
        uint256 userADecrease = userABalanceBefore - userABalanceAfter;
        uint256 userBIncrease = userBBalanceAfter - userBBalanceBefore;
        uint256 feeIncrease = feeWalletBalanceAfter - feeWalletBalanceBefore;

        console.log("UserA balance decreased by:", userADecrease);
        console.log("UserB balance increased by:", userBIncrease);
        console.log("FeeWallet balance increased by:", feeIncrease);

        // Vulnerability verdict based on state changes
        bool feeNotApplied = (userADecrease == TRANSFER_AMOUNT) && 
                           (userBIncrease == TRANSFER_AMOUNT) && 
                           (feeIncrease == 0);
        
        if (feeNotApplied) {
            console.log("Verdict: Vulnerability Exists - Transfer completed without applying fees");
        } else {
            console.log("Verdict: Vulnerability not Exist - Fees were correctly applied");
        }
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xDead);
    }
}

contract MockRouter {
    address immutable FACTORY;
    
    constructor(address _factory) {
        FACTORY = _factory;
    }
    
    function factory() external view returns (address) {
        return FACTORY;
    }
    
    function WETH() external pure returns (address) {
        return address(0xCafe);
    }
}