// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/RebaseDividendToken.sol";

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0x123);
    }
}

contract MockRouter {
    address public factory;
    
    constructor(address _factory) {
        factory = _factory;
    }
    
    function WETH() external pure returns (address) {
        return address(0x55d398326f99059fF775485246999027B3197955);
    }
}

contract WhitelistDuplicationTest is Test {
    RebaseDividendToken token;
    address owner = address(0x1);
    address user1 = address(0x2);
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Deploy mocks and set up router
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory));
        
        bytes memory mockRouterCode = address(mockRouter).code;
        vm.etch(ROUTER_ADDRESS, mockRouterCode);
        
        // Set storage slot 0 in router to contain mock factory address
        vm.store(
            ROUTER_ADDRESS,
            bytes32(0),
            bytes32(uint256(uint160(address(mockFactory))))
        );

        vm.startPrank(owner);
        token = new RebaseDividendToken();
        vm.stopPrank();
    }

    function testWhitelistDuplication() public {
        // Prepare address array
        address[] memory accounts = new address[](1);
        accounts[0] = user1;

        // Initially add user
        vm.prank(owner);
        token.addWhitelist(accounts);
        
        // Remove user
        vm.prank(owner);
        token.removeWhitelist(accounts);
        
        // Query state BEFORE re-add operation
        console.log("--- PRE-TRIGGER STATE (Before re-add) ---");
        address[] memory preState = token.whitelistedUsers();
        uint256 preLength = preState.length;
        console.log("Whitelist length:", preLength);
        console.log("Whitelist content:");
        for (uint i = 0; i < preLength; i++) {
            console.log("   Index %d: %s", i, preState[i]);
        }

        console.log("\n--- TRIGGER ACTION ---");
        console.log("Re-adding same user (should cause duplication)");
        // Re-add the same user to trigger vulnerability
        vm.prank(owner);
        token.addWhitelist(accounts);

        // Query state AFTER re-add operation
        console.log("\n--- POST-TRIGGER STATE (After re-add) ---");
        address[] memory postState = token.whitelistedUsers();
        uint256 postLength = postState.length;
        console.log("Whitelist length:", postLength);
        console.log("Whitelist content:");
        for (uint i = 0; i < postLength; i++) {
            console.log("   Index %d: %s", i, postState[i]);
        }

        // Differential verification
        console.log("\n--- DIFFERENTIAL VERDICT ---");
        bool duplicationDetected = postLength == 2 && 
                                    postState[0] == user1 && 
                                    postState[1] == user1;
        
        if (duplicationDetected) {
            console.log("STATE CHANGE DETECTED: Array length increased from %d to %d with duplicate entries", preLength, postLength);
            console.log("VULNERABILITY EXIST: Whitelist allows the same account to be added multiple times");
        } else {
            console.log("NO STATE CHANGE: Whitelist integrity maintained (%d entries)", postLength);
            console.log("Vulnerability not Exist: Whitelist prevents duplicate entries");
        }
    }
}