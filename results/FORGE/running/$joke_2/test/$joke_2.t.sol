// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";

interface IJOKE {
    function burn(address, uint256) external;
    function balanceOf(address) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function owner() external view returns (address);
}

contract JOKEBurnTest is Test {
    IJOKE token;
    address owner = address(0x10ED43);
    address user = address(0x1);
    uint initialSupply = 1000000 * 10**9;

    function setUp() public {
        vm.startPrank(owner);
        token = IJOKE(deployJokeToken());
        token.transfer(user, initialSupply / 2);
        vm.stopPrank();
    }

    function testOwnerCanBurnOthersTokens() public {
        // State before critical action
        uint userBalanceBefore = token.balanceOf(user);
        uint totalSupplyBefore = token.totalSupply();
        uint burnAmount = userBalanceBefore / 10;
        
        console.log("--- BEFORE-Trigger Burn ---");
        console.log("User balance:", userBalanceBefore);
        console.log("Total supply:", totalSupplyBefore);
        console.log("Planned burn amount:", burnAmount);

        // Validate initial state
        assertEq(userBalanceBefore, initialSupply / 2, "Initial user balance mismatch");
        assertTrue(burnAmount > 0, "Invalid burn amount");

        console.log("--- Trigger Burn ---");
        vm.prank(owner);
        token.burn(user, burnAmount);

        // State after critical action
        uint userBalanceAfter = token.balanceOf(user);
        uint totalSupplyAfter = token.totalSupply();
        
        console.log("--- AFTER-Trigger Burn ---");
        console.log("User balance:", userBalanceAfter);
        console.log("Total supply:", totalSupplyAfter);

        // Differential validation
        uint userBalanceDiff = userBalanceBefore - userBalanceAfter;
        uint totalSupplyDiff = totalSupplyBefore - totalSupplyAfter;
        bool validBurn = (userBalanceDiff == burnAmount) && 
                         (totalSupplyDiff == burnAmount);
        
        console.log("User balance reduction:", userBalanceDiff);
        console.log("Total supply reduction:", totalSupplyDiff);
        console.log("Expected reduction:", burnAmount);

        // Final verdict
        if (validBurn) {
            console.log("Vulnerability Exists: Owner can burn tokens without user consent");
        } else {
            console.log("Vulnerability not Exist: Burn operation failed");
        }
    }

    function deployJokeToken() internal returns (address) {
        bytes memory code = abi.encodePacked(type(JokeToken).creationCode);
        address deployed;
        assembly {
            deployed := create(0, add(code, 0x20), mload(code))
        }
        return deployed;
    }
}

contract JokeToken {
    mapping(address => uint256) public balanceOf; // Fixed capitalization
    uint256 public totalSupply;
    address public owner;

    constructor() public {
        owner = msg.sender;
        totalSupply = 1000000 * 10**9;
        balanceOf[msg.sender] = totalSupply;
    }

    function burn(address _from, uint256 _amount) public {
        require(msg.sender == owner, "Only owner can burn");
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}