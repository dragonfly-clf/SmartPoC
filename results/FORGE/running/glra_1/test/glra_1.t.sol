// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract MockRouter {
    address public immutable factory;
    address private immutable _WETH;

    constructor(address _factory, address weth) {
        factory = _factory;
        _WETH = weth;
    }

    function WETH() external view returns (address) {
        return _WETH;
    }
}

contract MockFactory {
    address public immutable pair;

    constructor(address _pair) {
        pair = _pair;
    }

    function createPair(address, address) external returns (address) {
        return pair;
    }
}

contract MockPair {
    function factory() external pure returns (address) {
        return address(0);
    }
}

contract CoinToken_SetSellTax_ExceedsLimit is Test {
    CoinToken token;
    address owner = address(0x1);
    uint256 initialSupply = 1000000 * 10**18;

    MockRouter public mockRouter;
    MockFactory public mockFactory;
    MockPair public mockPair;

    function setUp() public {
        mockPair = new MockPair();
        mockFactory = new MockFactory(address(mockPair));
        mockRouter = new MockRouter(
            address(mockFactory),
            address(0x123)  // Mock WETH
        );

        // Prepare constructor parameters
        string memory name = "TestToken";
        string memory symbol = "TT";
        address[6] memory addrs = [
            address(0x100),        // liquidity wallet
            address(mockRouter),    // router
            address(0x200),        // dev wallet
            address(0x300),        // marketing wallet
            address(0x400),        // charity wallet
            owner                 // owner
        ];

        // Initialize tax values
        uint256[8] memory values;
        values[0] = 0;  // buyTaxes[dev]
        values[1] = 0;  // buyTaxes[marketing]
        values[2] = 0;  // buyTaxes[charity]
        values[3] = 0;  // buyTaxes[liquidity]
        values[4] = 0;  // sellTaxes[dev]
        values[5] = 0;  // sellTaxes[marketing]
        values[6] = 0;  // sellTaxes[charity]
        values[7] = 0;  // sellTaxes[liquidity]

        // Deploy contract
        vm.deal(owner, 1 ether);
        vm.startPrank(owner);
        token = new CoinToken{value: 0.1 ether}(
            name,
            symbol,
            initialSupply,
            addrs,
            values
        );
        vm.stopPrank();
    }

    function testSetSellTaxExceeds25Percent() public {
        console2.log("--- BEFORE-Trigger SetSellTaxes ---");
        console2.log("Initial total sell tax: 0% (from constructor)");

        console2.log("--- Trigger: SetSellTax(10,10,10,10) -> 40% ---");
        bool successAt40;

        // Attempt to set sell tax to 40% total (10% per category)
        vm.startPrank(owner);
        (successAt40, ) = address(token).call(
            abi.encodeWithSignature("setSellTax(uint256,uint256,uint256,uint256)", 10, 10, 10, 10)
        );
        vm.stopPrank();

        if (successAt40) {
            console2.log("Result: Tax set to 40% (expected: <25%). VULNERABILITY INDICATED.");

            console2.log("--- Trigger: SetSellTax(20,20,20,20) -> 80% ---");
            vm.startPrank(owner);
            (bool successAt80, ) = address(token).call(
                abi.encodeWithSignature("setSellTax(uint256,uint256,uint256,uint256)", 20, 20, 20, 20)
            );
            vm.stopPrank();
            
            if (successAt80) {
                console2.log("Result: Tax set to 80%. VULNERABILITY CONFIRMED.");
            }
            console2.log("Vulnerability Exists: Owner set sell tax above 25%%");
        } else {
            console2.log("Result: Transaction reverted (expected behavior).");
            console2.log("Vulnerability not Exist: setSellTax reverts above 25%%");
        }
    }
}