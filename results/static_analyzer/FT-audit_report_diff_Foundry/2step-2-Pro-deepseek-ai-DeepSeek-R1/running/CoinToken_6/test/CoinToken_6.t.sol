// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

// MockFactory contract to simulate Uniswap factory
contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234); // Return dummy pair address
    }
}

// MockRouter contract to simulate Uniswap router
contract MockRouter {
    address public factory;
    address public weth = address(0x1); // Dummy WETH address

    constructor(address _factory) {
        factory = _factory;
    }

    function WETH() external view returns (address) {
        return weth;
    }
}

contract CoinTokenOwnershipTest is Test {
    CoinToken token;
    address owner = makeAddr("owner");
    address maliciousContract = makeAddr("maliciousContract");
    MockFactory mockFactory;
    MockRouter mockRouter;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setUp() public {
        // Fund owner with ETH for deployment
        vm.deal(owner, 10 ether);
        
        // Deploy mock contracts
        mockFactory = new MockFactory();
        mockRouter = new MockRouter(address(mockFactory));
        
        // Deploy CoinToken with valid parameters
        vm.prank(owner);
        token = new CoinToken{value: 1 wei}(
            "TestToken", 
            "TT", 
            1000000000,   // Total supply
            1,            // Tax fee
            2,            // Buyback fee
            3,            // Marketing fee
            owner,        // Marketing address
            address(mockRouter), // Router address
            owner         // LP address - will receive deployment ETH
        );
    }

    function test_MaliciousOwnershipTransfer() public {
        // Verify initial owner
        assertEq(token.owner(), owner, "Initial owner should be setup owner");

        console.log("--- BEFORE-Trigger Owner ---");
        address preOwner = token.owner();
        console.log("Current owner address: %s", preOwner);

        console.log("--- Trigger Ownership Transfer ---");
        // Transfer ownership to malicious contract
        vm.expectEmit(true, true, true, true);
        emit OwnershipTransferred(owner, maliciousContract);
        vm.prank(owner);
        token.transferOwnership(maliciousContract);
        
        console.log("--- AFTER-Trigger Owner ---");
        address postOwner = token.owner();
        console.log("New owner address: %s", postOwner);
        
        // Verify new owner is malicious contract
        assertEq(postOwner, maliciousContract, "Ownership not transferred to malicious contract");
        
        // Vulnerability verdict
        if (postOwner == maliciousContract) {
            console.log("Vulnerability Exists: Ownership successfully transferred to malicious contract");
        } else {
            console.log("Vulnerability not Exist: Ownership transfer failed");
        }
    }

    function test_ZeroAddressOwnershipTransfer() public {
        console.log("--- BEFORE-Trigger Owner ---");
        address preOwner = token.owner();
        console.log("Current owner address: %s", preOwner);

        console.log("--- Trigger Ownership Transfer to Zero Address ---");
        // Attempt to transfer to zero address
        vm.prank(owner);
        vm.expectRevert("Ownable: new owner is the zero address");
        token.transferOwnership(address(0));
        
        console.log("--- AFTER-Trigger Owner ---");
        address postOwner = token.owner();
        console.log("Owner after transfer attempt: %s", postOwner);
        
        // Vulnerability verdict
        if (preOwner == postOwner) {
            console.log("Vulnerability not Exist: Reverted correctly, ownership unchanged");
        } else {
            console.log("Vulnerability Exists: Ownership changed unexpectedly");
        }
    }

    function test_OwnershipTransferToContractItself() public {
        address tokenAddress = address(token);
        
        console.log("--- BEFORE-Trigger Owner ---");
        address preOwner = token.owner();
        console.log("Current owner address: %s", preOwner);
        
        console.log("--- Trigger Ownership Transfer to Self ---");
        // Transfer ownership to the token contract itself
        vm.expectEmit(true, true, true, true);
        emit OwnershipTransferred(owner, tokenAddress);
        vm.prank(owner);
        token.transferOwnership(tokenAddress);
        
        console.log("--- AFTER-Trigger Owner ---");
        address postOwner = token.owner();
        console.log("New owner address: %s", postOwner);
        
        // Verify new owner is the token contract
        assertEq(postOwner, tokenAddress, "Ownership not transferred to contract itself");
        
        // Vulnerability verdict
        if (postOwner == tokenAddress) {
            console.log("Vulnerability Exists: Ownership successfully transferred to contract itself");
        } else {
            console.log("Vulnerability not Exist: Ownership transfer to contract failed");
        }
    }
}