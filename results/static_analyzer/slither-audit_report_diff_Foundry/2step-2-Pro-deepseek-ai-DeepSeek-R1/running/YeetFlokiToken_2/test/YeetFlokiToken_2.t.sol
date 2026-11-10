// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/YeetFlokiToken.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1111);
    }
}

contract MockRouter {
    MockFactory public factory;
    address public weth;

    constructor(address _weth) {
        factory = new MockFactory();
        weth = _weth;
    }

    function WETH() external view returns (address) {
        return weth;
    }
}

contract FailingERC20 {
    function transfer(address, uint256) external pure returns (bool) {
        return false;
    }
}

contract YeetFlokiTokenTest is Test {
    YeetFlokiToken token;
    FailingERC20 failingToken;
    address constant owner = address(0xBEEF);
    address constant tokenRecipient = address(0xCAFE);
    address constant dummyWeth = 0xdEad000000000000000000000000000000000000;

    function setUp() public {
        // Create mock router with dummy WETH
        MockRouter mockRouter = new MockRouter(dummyWeth);
        vm.startPrank(owner);
        token = new YeetFlokiToken(address(mockRouter));
        failingToken = new FailingERC20();
        vm.stopPrank();
    }

    function testRescueTokensIgnoresTransferFailure() public {
        console.log("--- BEFORE-Trigger Status ---");
        console.log("No state change expected (vulnerability type: no_state)");

        console.log("--- Trigger Operation: rescueAnyERC20Tokens ---");
        vm.startPrank(owner);
        (bool success, ) = address(token).call(
            abi.encodeWithSelector(
                token.rescueAnyERC20Tokens.selector, 
                address(failingToken), 
                tokenRecipient, 
                100 ether
            )
        );
        vm.stopPrank();

        console.log("--- AFTER-Trigger Status ---");
        console.log("No state change captured (vulnerability type: no_state)");

        // Vulnerability verdict based on call success
        if (success) {
            console.log("Vulnerability Exists: rescueAnyERC20Tokens ignored transfer failure without reverting");
        } else {
            console.log("Vulnerability not Exist: rescueAnyERC20Tokens reverted on transfer failure");
        }
    }
}