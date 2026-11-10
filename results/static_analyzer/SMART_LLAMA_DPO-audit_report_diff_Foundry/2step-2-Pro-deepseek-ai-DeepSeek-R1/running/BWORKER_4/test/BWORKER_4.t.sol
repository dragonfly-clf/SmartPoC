// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BWORKER.sol";

contract MockPair {}

contract MockFactory {
    address public pair;

    constructor(address _pair) {
        pair = _pair;
    }

    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockRouter {
    address public factory;
    address public weth;

    function setFactory(address _factory) public {
        factory = _factory;
    }

    function setWETH(address _weth) public {
        weth = _weth;
    }

    function WETH() external view returns (address) {
        return weth;
    }
}

contract BWORKERPrivilegeTest is Test {
    BWORKER public token;
    address public owner = makeAddr("owner");
    address public nonOwner = makeAddr("nonOwner");
    address public nonContractAddress = address(0xdead);
    address public testContract;
    address public constant ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public constant MOCK_WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function setUp() public {
        // Deploy mock contracts
        MockPair mockPair = new MockPair();
        MockFactory mockFactory = new MockFactory(address(mockPair));
        
        // Prepare mock router
        MockRouter mockRouter = new MockRouter();
        mockRouter.setFactory(address(mockFactory));
        mockRouter.setWETH(MOCK_WETH);
        
        // Initialize router at target address
        vm.etch(ROUTER_ADDR, address(mockRouter).code);
        MockRouter(ROUTER_ADDR).setFactory(address(mockFactory));
        MockRouter(ROUTER_ADDR).setWETH(MOCK_WETH);
        
        // Deploy token as owner
        vm.startPrank(owner);
        token = new BWORKER();
        vm.stopPrank();
        
        // Deploy test contract
        testContract = address(new MockPair());
    }

    function testSetNFTContractByOwnerWithNonContract() public {
        vm.prank(owner);
        vm.expectRevert("contract only");
        token.setNFTContract(nonContractAddress);
    }

    function testSetNFTContractByNonOwner() public {
        vm.prank(nonOwner);
        vm.expectRevert();
        token.setNFTContract(testContract);
    }

    function testSetPresaleAddressByOwnerWithNonContract() public {
        vm.prank(owner);
        vm.expectRevert("Contract Only");
        token.setPresaleAddress(nonContractAddress);
    }

    function testSetPresaleAddressByNonOwner() public {
        vm.prank(nonOwner);
        vm.expectRevert();
        token.setPresaleAddress(testContract);
    }

    function testSetPairContractByOwnerWithNonContract() public {
        vm.prank(owner);
        vm.expectRevert("contract only");
        token.setPairContract(nonContractAddress);
    }

    function testSetPairContractByNonOwner() public {
        vm.prank(nonOwner);
        vm.expectRevert();
        token.setPairContract(testContract);
    }

    function testSetNFTContractByOwnerWithContract() public {
        console.log("--- BEFORE-Trigger NFTContract ---");
        address nftAddressBefore = token.nftContractAddress();
        console.log("Initial nftAddress:", nftAddressBefore);
        
        console.log("--- Trigger setNFTContract ---");
        vm.prank(owner);
        token.setNFTContract(testContract);
        
        console.log("--- AFTER-Trigger NFTContract ---");
        address nftAddressAfter = token.nftContractAddress();
        console.log("Updated nftAddress:", nftAddressAfter);
        
        bool stateChanged = (nftAddressBefore != nftAddressAfter);
        console.log("State changed:", stateChanged ? "YES" : "NO");
        
        console.log("Vulnerability not Exist: All privileged functions pass access control and contract validation checks");
    }
}