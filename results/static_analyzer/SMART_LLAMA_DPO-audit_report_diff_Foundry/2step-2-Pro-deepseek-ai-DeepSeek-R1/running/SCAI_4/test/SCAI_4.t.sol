// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SCAI.sol";

contract SCAIPrivilegeEscalationTest is Test {
    SCAI public token;
    address deployer = makeAddr("deployer");
    address marketingWallet = makeAddr("marketing");
    address attacker = makeAddr("attacker");
    address dummyPresale = makeAddr("presale");
    address dummyLpPair = makeAddr("lpPair");
    
    // Dummy router and WETH addresses
    address constant MAINNET_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address dummyWeth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address mockFactory = address(0x123456);

    // Function selectors
    bytes4 constant FACTORY_SELECTOR = bytes4(keccak256("factory()"));
    bytes4 constant WETH_SELECTOR = bytes4(keccak256("WETH()"));
    bytes4 constant CREATE_PAIR_SELECTOR = bytes4(keccak256("createPair(address,address)"));

    function setUp() public {
        // Set chain ID to Ethereum mainnet
        vm.chainId(1);
        
        // Setup mock router calls
        vm.mockCall(
            MAINNET_ROUTER, 
            abi.encodeWithSelector(FACTORY_SELECTOR),
            abi.encode(mockFactory)
        );
        
        vm.mockCall(
            MAINNET_ROUTER, 
            abi.encodeWithSelector(WETH_SELECTOR),
            abi.encode(dummyWeth)
        );
        
        // Setup mock factory createPair
        vm.mockCall(
            mockFactory,
            abi.encodePacked(CREATE_PAIR_SELECTOR),
            abi.encode(dummyLpPair)
        );

        // Deploy token contract as owner
        vm.startPrank(deployer);
        token = new SCAI();
        vm.stopPrank();
    }

    // Test for changeWallets vulnerability (non-owner)
    function test_nonOwnerCannotChangeMarketingWallet() public {
        vm.prank(attacker);
        (bool success, ) = address(token).call(
            abi.encodeWithSelector(token.changeWallets.selector, attacker)
        );

        if (success) {
            console.log("Vulnerability Exists: Non-owner changed marketing wallet");
            fail();
        } else {
            console.log("Vulnerability not Exist: Non-owner cannot change marketing wallet");
        }
    }

    // Test for toggleCanSwapFees vulnerability (non-owner)
    function test_nonOwnerCannotToggleFeeSwapping() public {
        vm.prank(attacker);
        (bool success, ) = address(token).call(
            abi.encodeWithSelector(token.toggleCanSwapFees.selector, true)
        );

        if (success) {
            console.log("Vulnerability Exists: Non-owner toggled fee swapping");
            fail();
        } else {
            console.log("Vulnerability not Exist: Non-owner cannot toggle fee swapping");
        }
    }

    // Test for enableTrading vulnerability (non-owner)
    function test_nonOwnerCannotEnableTrading() public {
        vm.prank(attacker);
        (bool success, ) = address(token).call(
            abi.encodeWithSelector(token.enableTrading.selector)
        );

        if (success) {
            console.log("Vulnerability Exists: Non-owner enabled trading");
            fail();
        } else {
            console.log("Vulnerability not Exist: Non-owner cannot enable trading");
        }
    }

    // Test for changeLpPair vulnerability (non-owner)
    function test_nonOwnerCannotChangeLpPair() public {
        vm.prank(attacker);
        (bool success, ) = address(token).call(
            abi.encodeWithSelector(token.changeLpPair.selector, address(0xabc))
        );

        if (success) {
            console.log("Vulnerability Exists: Non-owner changed LP pair");
            fail();
        } else {
            console.log("Vulnerability not Exist: Non-owner cannot change LP pair");
        }
    }

    // Test for setPresaleAddress vulnerability (non-owner)
    function test_nonOwnerCannotSetPresaleAddress() public {
        vm.prank(attacker);
        (bool success, ) = address(token).call(
            abi.encodeWithSelector(token.setPresaleAddress.selector, dummyPresale, true)
        );

        if (success) {
            console.log("Vulnerability Exists: Non-owner set presale address");
            fail();
        } else {
            console.log("Vulnerability not Exist: Non-owner cannot set presale address");
        }
    }

    // Below are the original tests (owners/test edges) - UNMODIFIED
    function test_ownerCanChangeMarketingWallet() public {
        vm.prank(deployer);
        token.changeWallets(marketingWallet);
    }

    function test_zeroAddressMarketingWallet() public {
        vm.prank(deployer);
        vm.expectRevert();
        token.changeWallets(address(0));
    }

    function test_ownerCanToggleFeeSwapping() public {
        vm.prank(deployer);
        token.toggleCanSwapFees(true);
        
        vm.prank(deployer);
        token.toggleCanSwapFees(false);
    }

    function test_ownerCanEnableTrading() public {
        vm.prank(deployer);
        token.enableTrading();
        
        // Ensure trading can only be enabled once
        vm.prank(deployer);
        vm.expectRevert("Trading already enabled");
        token.enableTrading();
    }

    function test_ownerCanChangeLpPair() public {
        vm.prank(deployer);
        token.changeLpPair(address(0xabc));
    }

    function test_ownerCanSetPresaleAddress() public {
        vm.prank(deployer);
        token.setPresaleAddress(dummyPresale, true);
        
        vm.prank(deployer);
        token.setPresaleAddress(dummyPresale, false);
    }
}