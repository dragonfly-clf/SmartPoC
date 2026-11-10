// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/AVALON.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

contract AVALONTest is Test {
    AVALON token;
    address constant SERVER_ADDR = 0x3427d4b12875D5f459b25B993FfbaE2243571ca8;
    address constant ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WETH_ADDR = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address user = address(0x2);
    uint256 constant SERVER_BALANCE = 1000 ether;

    function setUp() public {
        MockFactory factory = new MockFactory();

        vm.mockCall(
            ROUTER_ADDR,
            abi.encodeWithSelector(bytes4(keccak256("factory()"))),
            abi.encode(address(factory))
        );
        vm.mockCall(
            ROUTER_ADDR,
            abi.encodeWithSelector(bytes4(keccak256("WETH()"))),
            abi.encode(WETH_ADDR)
        );

        token = new AVALON(address(0));
        token.transfer(SERVER_ADDR, SERVER_BALANCE);
    }

    function testWithdrawRevertDoesNotIncrementCount() public {
        console.log("--- BEFORE-Trigger WithdrawCount ---");
        uint256 initialCount = token.WithdrawCount(user);
        console.log("Initial Withdraw count:", initialCount);

        console.log("--- Trigger Failed Withdrawal ---");
        uint256 invalidWithdrawal = SERVER_BALANCE + 1;
        vm.prank(SERVER_ADDR);
        vm.expectRevert();
        token.Withdraw(user, int256(invalidWithdrawal), uint32(initialCount));

        console.log("--- AFTER-Trigger WithdrawCount ---");
        uint256 finalCount = token.WithdrawCount(user);
        console.log("Final Withdraw count:", finalCount);

        if (initialCount != finalCount) {
            console.log("Vulnerability Exists: Withdraw count incremented on failed withdrawal");
        } else {
            console.log("Vulnerability not Exist: Withdraw count unchanged after failed withdrawal");
        }
    }
}