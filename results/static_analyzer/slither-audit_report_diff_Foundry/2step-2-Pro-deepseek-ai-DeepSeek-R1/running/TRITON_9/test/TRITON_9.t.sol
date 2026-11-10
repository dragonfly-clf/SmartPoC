// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TRITON.sol";

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0x123456);
    }
}

contract MockRouter {
    address public immutable factory;

    constructor(address _factory) {
        factory = _factory;
    }

    function WETH() external pure returns (address) {
        return address(1);
    }
}

contract TestTRITONMultiSend is Test {
    TRITON token;
    address owner = address(0x1);
    address contributor1 = address(0x2);
    address contributor2 = makeAddr("malicious_contributor");
    address[] contributors;
    uint256[] balances;

    function setUp() public {
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory));
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        vm.etch(routerAddress, address(mockRouter).code);

        vm.startPrank(owner);
        token = new TRITON();
        
        contributors.push(contributor1);
        contributors.push(contributor2);
        
        balances.push(1e20);
        balances.push(1e20);
        
        token.approve(address(token), token.balanceOf(owner));
        vm.stopPrank();
    }

    function testTransferFailureIgnored() public {
        console2.log("--- BEFORE-Trigger Setup ---");
        console2.log("Mocking failed transfer for contributor2");
        
        vm.mockCall(
            address(token),
            abi.encodeWithSelector(token.balanceOf.selector, contributor2),
            abi.encode(0)
        );

        vm.mockCall(
            address(token),
            abi.encodeWithSelector(
                token.transferFrom.selector,
                owner,
                contributor2,
                1e20
            ),
            abi.encode(false)
        );

        console2.log("--- Trigger multiSend ---");
        bool vulnerable = false;
        string memory verdictReason;

        vm.startPrank(owner);
        try token.multiSend(contributors, balances) {
            vulnerable = true;
            verdictReason = "Contract executed multiSend without reverting on failed transfer";
        } catch Error(string memory reason) {
            if (keccak256(bytes(reason)) == keccak256(bytes("Contributor must recieve full balance of airdrop"))) {
                vulnerable = false;
                verdictReason = "Contract reverted as expected";
            } else {
                revert(string(abi.encodePacked("Unexpected revert reason: ", reason)));
            }
        } catch (bytes memory lowLevelData) {
            revert(string(abi.encodePacked("Unexpected low-level error")));
        }
        vm.stopPrank();

        console2.log("--- AFTER-Trigger Verification ---");
        if (vulnerable) {
            console2.log("Vulnerability Exists: ", verdictReason);
        } else {
            console2.log("Vulnerability not Exist: ", verdictReason);
        }
    }
}