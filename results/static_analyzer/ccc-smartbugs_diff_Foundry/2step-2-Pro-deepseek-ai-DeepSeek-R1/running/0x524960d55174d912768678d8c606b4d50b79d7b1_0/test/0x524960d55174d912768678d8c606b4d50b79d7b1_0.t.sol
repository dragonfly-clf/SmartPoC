// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x524960d55174d912768678d8c606b4d50b79d7b1.sol";

contract Centra4Test is Test {
    Centra4 centra;
    address constant CONTRACT_ADDR = 0x96A65609a7B84E8842732DEB08f56C3E21aC6f8a;
    address constant C2 = 0xAa27f8C1160886aacba64B2319D8d5469ef2Af79;
    
    event TransferExecuted(address indexed sender, address indexed to, uint256 amount, bool success);

    function setUp() public {
        centra = new Centra4();
    }

    function test_MissingExternalCallCheck() public {
        address user = makeAddr("user");
        uint256 userInitial;
        uint256 globalInitial;
        (userInitial, globalInitial) = centra.getTransferStats(user);

        console2.log("--- BEFORE-Trigger ---");
        console2.log("Initial user transfers: ", userInitial);
        console2.log("Initial global transfers: ", globalInitial);

        // Mock first external call to fail
        vm.mockCall(
            CONTRACT_ADDR,
            abi.encodeWithSignature("register(string)", "CentraToken"),
            abi.encode(false)
        );
        
        // Mock second external call to succeed
        vm.mockCall(
            CONTRACT_ADDR,
            abi.encodeWithSignature("transfer(address,uint256)", C2, 1),
            abi.encode(true)
        );

        // Capture event with parameters
        vm.expectEmit(true, true, true, true, address(centra));
        emit TransferExecuted(user, C2, 1, true);

        console2.log("--- Trigger Transfer ---");
        vm.prank(user);
        centra.transfer();

        console2.log("--- AFTER-Trigger ---");
        (uint256 userFinal, uint256 globalFinal) = centra.getTransferStats(user);
        console2.log("Final user transfers: ", userFinal);
        console2.log("Final global transfers: ", globalFinal);

        uint256 userChange = userFinal - userInitial;
        uint256 globalChange = globalFinal - globalInitial;
        
        console2.log("User transfers change: ", userChange);
        console2.log("Global transfers change: ", globalChange);

        if (userChange == 1 && globalChange == 1) {
            console2.log("Vulnerability Exists: State updated despite failed external call");
        } else {
            console2.log("Vulnerability not Exist: State not updated as expected");
        }
    }
}