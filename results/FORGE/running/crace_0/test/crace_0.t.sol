// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CryptoRace.sol";

contract MockRouter {
    address public immutable factoryAddress;
    
    constructor(address factory_) {
        factoryAddress = factory_;
    }
    
    function factory() external view returns (address) {
        return factoryAddress;
    }
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0xABCD);
    }
}

contract CryptoRaceFeeManipulationTest is Test {
    CryptoRace token;
    address owner = makeAddr("owner");
    address constant routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Create mock factory and router
        vm.startPrank(owner);
        
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory));
        
        // Patch real router address with mock
        vm.etch(routerAddress, address(mockRouter).code);
        
        // Deploy main contract
        token = new CryptoRace();
        vm.stopPrank();
    }

    function test_FeeCanExceed25Percent() public {
        uint256 denominator = 100;
        uint256 feePerComponent = 7; // 7% per component
        uint256 totalFee = feePerComponent * 4; // 28% total

        // Verify test is above 25% threshold
        assertGt(totalFee, 25, "Test fee must be above 25%");

        console.log("--- BEFORE-Trigger Fee Query ---");
        uint256 initialFee = token.getTotalFee(false);
        console.log("Initial total buy fee:", initialFee);

        console.log("--- Trigger ChangeFee ---");
        // Attempt unsafe fee setting
        vm.prank(owner);
        token.setFees(
            feePerComponent, 
            feePerComponent, 
            feePerComponent, 
            feePerComponent, 
            denominator
        );
        
        console.log("--- AFTER-Trigger Fee Query ---");
        uint256 newFee = token.getTotalFee(false);
        console.log("New total buy fee:", newFee);

        // Vulnerability confirmation logic
        if (newFee > 25) {
            console.log("Vulnerability Exists: Fee set above 25 percent (actual: %s%%)", newFee);
        } else {
            console.log("Vulnerability not Exist: Fee at %s%% <=25%% threshold", newFee);
        }
    }
}