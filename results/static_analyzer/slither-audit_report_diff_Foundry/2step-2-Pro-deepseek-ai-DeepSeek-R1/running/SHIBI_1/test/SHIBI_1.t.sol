// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SHIBI.sol";

// Helper contract that can simulate failed transfers
contract FlakyToken {
    mapping(address => uint256) public balanceOf;
    bool public shouldFail;

    constructor(uint256 supply) public {
        balanceOf[msg.sender] = supply;
    }

    function setFail(bool _fail) external {
        shouldFail = _fail;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        if (shouldFail) {
            return false;
        } else {
            balanceOf[msg.sender] -= amount;
            balanceOf[to] += amount;
            return true;
        }
    }
}

contract SHIBIRemoveStuckTokenTest is Test {
    SHIBI token;
    FlakyToken flakyToken;
    address owner = address(0x1234);
    address constant ROUTER_ADDRESS = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address constant WETH_ADDRESS = address(0x6);

    function setUp() public {
        // Setup mock calls for Uniswap dependencies
        vm.startPrank(owner);
        
        // Mock router factory call
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(bytes4(keccak256("factory()"))),
            abi.encode(address(0))
        );
        
        // Mock router WETH call
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(bytes4(keccak256("WETH()"))),
            abi.encode(WETH_ADDRESS)
        );
        
        // Mock factory createPair call
        vm.mockCall(
            address(0),
            abi.encodeWithSelector(bytes4(keccak256("createPair(address,address)"))),
            abi.encode(address(0))
        );
        
        // Deploy main token contract
        token = new SHIBI();
        
        // Deploy flaky token that can fail transfers
        flakyToken = new FlakyToken(1000 ether);
        
        // Send tokens to SHIBI contract
        flakyToken.transfer(address(token), 500 ether);
        
        vm.stopPrank();
    }

    function test_RemoveStuckToken_FailedTransferStillDrainsBalance() public {
        // 1. Check initial state before vulnerability trigger
        emit log("--- BEFORE-Trigger State ---");
        uint256 initialContractBalance = flakyToken.balanceOf(address(token));
        uint256 initialOwnerBalance = flakyToken.balanceOf(owner);
        emit log_named_uint("Contract balance before", initialContractBalance);
        emit log_named_uint("Owner balance before", initialOwnerBalance);

        // Make sure flaky token transfers will fail
        vm.prank(owner);
        flakyToken.setFail(true);
        
        // 2. Trigger vulnerable operation
        emit log("--- Trigger Operation: removeStuckToken ---");
        vm.prank(owner);
        token.removeStuckToken(address(flakyToken));
        
        // 3. Check state after vulnerability trigger
        emit log("--- AFTER-Trigger State ---");
        uint256 finalContractBalance = flakyToken.balanceOf(address(token));
        uint256 finalOwnerBalance = flakyToken.balanceOf(owner);
        emit log_named_uint("Contract balance after", finalContractBalance);
        emit log_named_uint("Owner balance after", finalOwnerBalance);
        
        // 4. Compare state changes
        bool balancesUnchanged = 
            (finalContractBalance == initialContractBalance) &&
            (finalOwnerBalance == initialOwnerBalance);
        
        emit log("--- Result Analysis ---");
        emit log_named_string("Balances unchanged", balancesUnchanged ? "true" : "false");
        
        // 5. Final verdict
        if (balancesUnchanged) {
            emit log("Vulnerability Exists: Balances remain unchanged after failed transfer");
        } else {
            emit log("Vulnerability not Exist: Balances changed despite transfer failure");
        }
    }
}