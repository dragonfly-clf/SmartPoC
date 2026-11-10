// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ELONPETS.sol";

contract MockRouter {
    address public factory;
    address public WETH;
    
    constructor() {
        // Initialized via setters
    }
    
    function setFactory(address _factory) public {
        factory = _factory;
    }
    
    function setWETH(address _weth) public {
        WETH = _weth;
    }
    
    function createPair(address, address) external returns (address pair) {
        return address(0xdead);
    }
    
    function addLiquidityETH(
        address,
        uint,
        uint,
        uint,
        address,
        uint
    ) external payable returns (uint, uint, uint) {
        return (0, 0, 0);
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint,
        uint,
        address[] calldata,
        address,
        uint
    ) external {}
    
    // Other stubs for unneeded router functions
    function addLiquidity(address, address, uint, uint, uint, uint, address, uint)
        external pure returns (uint, uint, uint) { return (0,0,0); }
    
    function removeLiquidity(address, address, uint, uint, uint, address, uint)
        external pure returns (uint, uint) { return (0,0); }
    
    function swapExactTokensForTokens(uint, uint, address[] calldata, address, uint)
        external pure returns (uint[] memory) { uint[] memory empty; return empty; }
}

contract ElonPetsMultiTransferTest is Test {
    ELONPETS public token;
    address public owner = address(0xCAFE);
    address public receiver = address(0xBEEF);
    uint256 public totalSupply;

    function setUp() public {
        // Deploy MockFactory
        address mockFactory = address(new MockRouter());
        // Deploy router template for code
        MockRouter mockRouterTemplate = new MockRouter();
        
        // Set real router address to use mock
        address realRouter = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        vm.etch(realRouter, address(mockRouterTemplate).code);
        
        // Initialize router storage
        MockRouter router = MockRouter(realRouter);
        router.setFactory(mockFactory);
        router.setWETH(address(0x000000000000000000000000000000000000dEaD));
        
        // Deploy main contract as owner
        vm.startPrank(owner);
        token = new ELONPETS();
        totalSupply = token.totalSupply();
        vm.stopPrank();
        
        // Configure token settings for test
        vm.startPrank(owner);
        // Disable antibot features
        token.manage_blacklist_status(false);
        // Disable blacklist for transfers
        vm.stopPrank();
    }

    function testDuplicateAddressMultiTransfer() public {
        vm.startPrank(owner);
        
        // Set up duplicate addresses
        address[] memory addresses = new address[](3);
        addresses[0] = receiver;
        addresses[1] = receiver;
        addresses[2] = receiver;
        
        // Distribute 1% of supply per transfer
        uint256 amountPerTransfer = totalSupply / 100;
        uint256[] memory amounts = new uint256[](3);
        amounts[0] = amountPerTransfer;
        amounts[1] = amountPerTransfer;
        amounts[2] = amountPerTransfer;
        uint256 totalAmount = 3 * amountPerTransfer;

        // --- BEFORE-Trigger Balances ---
        console.log("--- BEFORE-Trigger Balances ---");
        uint256 ownerBefore = token.balanceOf(owner);
        uint256 receiverBefore = token.balanceOf(receiver);
        console.log("Owner balance before: %s", ownerBefore);
        console.log("Receiver balance before: %s", receiverBefore);

        // Trigger multiTransfer
        console.log("--- Trigger multiTransfer ---");
        token.multiTransfer(owner, addresses, amounts);

        // --- AFTER-Trigger Balances ---
        console.log("--- AFTER-Trigger Balances ---");
        uint256 ownerAfter = token.balanceOf(owner);
        uint256 receiverAfter = token.balanceOf(receiver);
        console.log("Owner balance after: %s", ownerAfter);
        console.log("Receiver balance after: %s", receiverAfter);

        // Calculate actual changes
        uint256 actualReceiverIncrease = receiverAfter - receiverBefore;
        uint256 actualOwnerDecrease = ownerBefore - ownerAfter;

        console.log("Expected total transfer amount: %s", totalAmount);
        console.log("Actual receiver increase: %s", actualReceiverIncrease);
        console.log("Actual owner decrease: %s", actualOwnerDecrease);

        // Check if the duplication vulnerability exists
        if (actualReceiverIncrease == totalAmount && actualOwnerDecrease == totalAmount) {
            console.log("Vulnerability not Exist: The contract correctly processed multiple transfers to the same address");
        } else {
            console.log("Vulnerability Exists: The contract did not process duplicate transfers correctly (likely only one transfer occurred)");
        }
        vm.stopPrank();
    }
}