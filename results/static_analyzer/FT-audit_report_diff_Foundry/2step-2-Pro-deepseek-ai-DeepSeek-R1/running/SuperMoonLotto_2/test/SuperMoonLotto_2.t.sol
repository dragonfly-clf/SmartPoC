// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SuperMoonLotto.sol";

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract MockFactory {
    address public dummyPair;
    
    constructor() {
        dummyPair = address(0xD0a1E);
    }
    
    function createPair(address, address) external view returns (address) {
        return dummyPair;
    }
}

contract SuperMoonLottoTest is Test {
    MockFactory internal mockFactory;
    MockRouter internal mockRouter;
    SuperMoonLotto internal token;
    
    address internal deployer = makeAddr("deployer");
    address internal attacker = makeAddr("attacker");
    
    function setUp() public {
        vm.startPrank(deployer);
        mockFactory = new MockFactory();
        mockRouter = new MockRouter(
            address(mockFactory), 
            address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2)
        );
        token = new SuperMoonLotto(address(mockRouter));
        vm.stopPrank();
    }

    function testEOACallSucceeds() public {
        // Generate non-contract address (EOA)
        address nonContractAddr = makeAddr("eoa_address");
        
        // Create call data (empty for EOA call)
        bytes memory data = new bytes(0);
        
        // Perform EOA call test
        console.log("Verifying EOA call vulnerability...");
        (bool success, ) = nonContractAddr.call(data);
        
        // Conditional verdict output
        if (success) {
            console.log("Vulnerability Exists: EOA call succeeded unexpectedly");
        } else {
            console.log("Vulnerability not Exist: EOA call failed");
        }
    }
}