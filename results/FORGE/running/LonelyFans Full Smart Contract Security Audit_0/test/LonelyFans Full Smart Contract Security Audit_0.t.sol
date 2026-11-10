// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LonelyFans.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1);
    }
}

contract MockRouter {
    address public factory;
    address public WETH;
    
    constructor(address _factory) public {
        factory = _factory;
        WETH = address(0xBEEF);
    }
}

contract LonelyFansDistributionTest is Test {
    function getCode(address a) internal view returns (bytes memory) {
        uint256 size;
        assembly {
            size := extcodesize(a)
        }
        bytes memory code = new bytes(size);
        assembly {
            extcodecopy(a, add(code, 0x20), 0, size)
        }
        return code;
    }

    LonelyFans token;
    address constant routerAddress = 0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F;

    // Initial distribution addresses from the contract's constructor
    address[12] distributionAddresses = [
        0xb62Dc5706A658A5cc90c6bc1CE8FdA59da311294,
        0x10cD8079755bC23b7E644F60627478e62E8817D5,
        0x9922CCA9d7c9d24aF70152Ad49D267f8201b6E26,
        0xb844DE4E28f1862BF42496058E3F92BE260AA892,
        0x4fcaBdC310F888eaC8d9C8df5a872Af0fce46107,
        0x7C493655BAa088B9Ada56E77990f543d00ee079e,
        0x2531A2eCfD3835b010eF0C3C9F75ff2E691dB69C,
        0x2a34A7bca44628ec47dA6FA105B9f8E22a5e8FE3,
        0x571D73e3727ea29211fDaDF9b5560Ec79cCED8bC,
        0xdb845d0101874425b5bB7AcbFf0BfD7848881847,
        0xfb7a0B3e83Fc0673Bf96302e0b46ebAA75469219,
        0xF908d85578e19BC29F793EEaB46c1E859A2c3054
    ];

    function setUp() public {
        // Deploy mock factory
        MockFactory mockFactory = new MockFactory();
        
        // Deploy mock router and get its code
        MockRouter mockRouter = new MockRouter(address(mockFactory));
        bytes memory mockRouterCode = getCode(address(mockRouter));
        
        // Set router code at hardcoded address
        vm.etch(routerAddress, mockRouterCode);
        
        // Set necessary storage slots for router
        vm.store(
            routerAddress,
            bytes32(0),
            bytes32(uint256(uint160(address(mockFactory))))
        );
        vm.store(
            routerAddress,
            bytes32(uint256(1)),
            bytes32(uint256(0xBEEF))
        );
        
        // Deploy token contract
        token = new LonelyFans();
    }

    function testTokenDistributionExceeds100Percent() public {
        uint256 totalSupply = token.totalSupply();
        uint256 totalDistributed;
        
        console.log("--- Static State Snapshot ---");
        console.log("Total token supply:", totalSupply);
        
        // Sum balances of distribution addresses
        for (uint i = 0; i < distributionAddresses.length; i++) {
            uint256 addrBalance = token.balanceOf(distributionAddresses[i]);
            totalDistributed += addrBalance;
            console.log("Address %s received: %s tokens", distributionAddresses[i], addrBalance);
        }
        
        console.log("Total distributed to all addresses:", totalDistributed);
        console.log("Vulnerability verification ratio: %s / %s = %s%", totalDistributed, totalSupply, (totalDistributed * 100) / totalSupply);
        
        // Final vulnerability verdict
        if (totalDistributed > totalSupply) {
            emit log("Vulnerability Exists: Static distribution exceeds 100% of token supply");
        } else {
            emit log("Vulnerability not Exist: Token distribution within valid range");
        }
    }
}