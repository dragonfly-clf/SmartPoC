// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;
pragma experimental ABIEncoderV2;
import "forge-std/Test.sol";
import "../src/junkoInu.sol";

contract MockWETH {
    function deposit() external payable {}
    function withdraw(uint) external {}
}

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF);
    }
}

contract MockUniswapV2Router {
    address public factoryAddress;
    address public wethAddress;

    constructor(address _factory, address _weth) {
        factoryAddress = _factory;
        wethAddress = _weth;
    }

    function factory() external view returns (address) {
        return factoryAddress;
    }

    function WETH() external view returns (address) {
        return wethAddress;
    }
}

contract junkoInuDoSTest is Test {
    junkoInu public token;
    MockWETH public mockWETH;
    MockUniswapV2Factory public mockFactory;
    MockUniswapV2Router public mockRouter;
    address payable constant ROUTER_ADDRESS = payable(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address owner = address(0x1);

    function setUp() public {
        // Deploy mocks with proper addresses
        mockWETH = new MockWETH();
        mockFactory = new MockUniswapV2Factory();
        mockRouter = new MockUniswapV2Router(address(mockFactory), address(mockWETH));
        
        // Set router address code and storage
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        // Initialize mock router storage at real address
        vm.store(
            ROUTER_ADDRESS,
            bytes32(uint256(0)), 
            bytes32(uint256(uint160(address(mockFactory))))
        );
        vm.store(
            ROUTER_ADDRESS,
            bytes32(uint256(1)), 
            bytes32(uint256(uint160(address(mockWETH))))
        );
        
        // Deploy token contract
        vm.startPrank(owner);
        token = new junkoInu();
        vm.stopPrank();
    }

    function testCollectFeesDoesNotExist() public {
        console.log("--- BEFORE-Trigger ---");
        console.log("Check: Expected that collectFees function does not exist.");

        console.log("--- Trigger: Call collectFees ---");
        (bool success, ) = address(token).call(
            abi.encodeWithSignature("collectFees(address)", owner)
        );

        console.log("--- AFTER-Trigger ---");
        console.log("Function call result: success = ", success);

        // Print vulnerability verdict
        if (success) {
            console.log("Vulnerability Exists: collectFees function exists");
        } else {
            console.log("Vulnerability not Exist: collectFees function does not exist");
        }

        // Original assertion to validate test
        assertFalse(success, "collectFees function should not exist");
    }
}