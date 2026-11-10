// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PILOTDOGE.sol";

contract MockWETH {
    // Minimal implementation
}

contract MockPair {
    // Minimal implementation
}

contract MockFactory {
    address public pair;

    constructor(address _pair) {
        pair = _pair;
    }

    function createPair(address, address) external returns (address) {
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256, /* amountIn */
        uint256, /* amountOutMin */
        address[] calldata, /* path */
        address, /* to */
        uint256 /* deadline */
    ) external pure {
        // Minimal implementation
    }
}

contract PILOTDOGEAuditTest is Test {
    PILOTDOGE token;
    address owner = makeAddr("owner");
    address dev = makeAddr("dev");
    address marketing = makeAddr("marketing");
    
    // Hardcoded router address from PILOTDOGE contract
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Setup mock UniSwap contracts
        MockWETH mockWETH = new MockWETH();
        MockPair mockPair = new MockPair();
        MockFactory mockFactory = new MockFactory(address(mockPair));
        MockRouter mockRouter = new MockRouter(address(mockFactory), address(mockWETH));
        
        // Etch the router address with mock code
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        
        // Deploy PILOTDOGE contract
        vm.startPrank(owner);
        token = new PILOTDOGE();
        vm.stopPrank();
    }

    function test_setDevAddressIsZeroAddress() public {
        console.log("--- BEFORE-Trigger Action ---");
        // Cannot check private storage variables
        console.log("Starting dev address change test");

        console.log("--- Trigger setNewDevAddress ---");
        vm.prank(owner);
        token.setNewDevAddress(payable(address(0))); // No revert indicates vulnerability
        
        console.log("--- AFTER-Trigger Action ---");
        console.log("Vulnerability Exists: Function call didn't revert when setting zero dev address");
    }

    function test_setMarketingAddressIsZeroAddress() public {
        console.log("--- BEFORE-Trigger Action ---");
        // Cannot check private storage variables
        console.log("Starting marketing address change test");

        console.log("--- Trigger setNewMarketingAddress ---");
        vm.prank(owner);
        token.setNewMarketingAddress(payable(address(0))); // No revert indicates vulnerability
        
        console.log("--- AFTER-Trigger Action ---");
        console.log("Vulnerability Exists: Function call didn't revert when setting zero marketing address");
    }
}