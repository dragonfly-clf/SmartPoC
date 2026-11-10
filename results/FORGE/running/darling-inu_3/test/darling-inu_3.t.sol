// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DarlingInu.sol";

contract MockWETH {
    // Minimal implementation for WETH
    constructor() {}
}

contract MockPair {
    // Minimal implementation for pair contract
    constructor() {}
}

contract MockFactory {
    address public immutable pair;

    constructor(address _pair) {
        pair = _pair;
    }

    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract BlacklistTest is Test {
    address constant OWNER = 0x8c919e9F79686c6D5E6336B558349E13B864D621;
    DarlingInu token;
    
    address alice = address(0x1111);
    address bob = address(0x2222);

    function setUp() public {
        // Deploy mocks
        MockWETH mockWETH = new MockWETH();
        MockPair mockPair = new MockPair();
        MockFactory mockFactory = new MockFactory(address(mockPair));
        MockRouter mockRouter = new MockRouter(address(mockFactory), address(mockWETH));
        
        // Patch the router address with mock bytecode
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        vm.etch(routerAddress, address(mockRouter).code);
        
        // Deploy token
        token = new DarlingInu();
    }

    function testBlacklistAbility() public {
        vm.startPrank(OWNER);
        
        // Send Alice some tokens
        uint256 balance = token.balanceOf(OWNER);
        token.transfer(alice, balance / 2);
        
        // Blacklist Alice
        address[] memory wallets = new address[](1);
        wallets[0] = alice;
        token.blacklist_Add_Wallets(wallets);
        vm.stopPrank();

        // Pre-transfer balance check
        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 alicePreBalance = token.balanceOf(alice);
        uint256 bobPreBalance = token.balanceOf(bob);
        console.log("Alice balance before transfer: %s", alicePreBalance);
        console.log("Bob balance before transfer: %s", bobPreBalance);

        // Try to transfer from Alice to Bob
        console.log("--- Trigger Transfer ---");
        vm.startPrank(alice);
        uint256 aliceBalance = token.balanceOf(alice);
        vm.expectRevert();
        token.transfer(bob, aliceBalance);
        vm.stopPrank();

        // Post-transfer balance check
        console.log("--- AFTER-Trigger Transfer ---");
        uint256 alicePostBalance = token.balanceOf(alice);
        uint256 bobPostBalance = token.balanceOf(bob);
        console.log("Alice balance after transfer: %s", alicePostBalance);
        console.log("Bob balance after transfer: %s", bobPostBalance);

        // Vulnerability verification
        bool balancesUnchanged = (alicePreBalance == alicePostBalance) && 
                                 (bobPreBalance == bobPostBalance);
        
        if (balancesUnchanged) {
            console.log("Vulnerability Exists: Blacklist function successfully blocked Alice's transfer");
        } else {
            console.log("Vulnerability not Exist: Blacklist function failed to block transfers");
        }
    }
}