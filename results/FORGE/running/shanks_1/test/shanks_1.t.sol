// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SHANKS_INU.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xCAFE);
    }
}

contract MockRouter {
    address public factory;
    
    constructor(address _factory) {
        factory = _factory;
    }
    
    function WETH() external pure returns (address) {
        return address(0);
    }

    // Dummy implementations required by interface
    function addLiquidityETH(
        address, uint, uint, uint, address, uint
    ) external payable returns (uint, uint, uint) {
        return (0,0,0);
    }
    
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint, address[] calldata, address, uint
    ) external payable {}
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint, uint, address[] calldata, address, uint
    ) external {}
    
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint, uint, address[] calldata, address, uint
    ) external {}
}

contract SHANKS_INU_Test is Test {
    SHANKS_INU token;
    address owner = address(0x12345);
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    // Storage slots based on contract layout
    uint constant TOTAL_FEE_SLOT = 25;
    uint constant FEE_DENOMINATOR_SLOT = 26;

    function setUp() public {
        // Create mock factory
        MockFactory mockFactory = new MockFactory();
        
        // Create mock router pointing to mock factory
        MockRouter mockRouter = new MockRouter(address(mockFactory));
        
        // Deploy router mock to target address
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        
        // Set storage slot for factory address in mock router
        vm.store(
            ROUTER_ADDRESS,
            bytes32(uint256(0)),
            bytes32(uint256(uint160(address(mockFactory))))
        );

        // Deploy actual token contract
        vm.startPrank(owner);
        token = new SHANKS_INU();
        vm.stopPrank();
    }

    function test_setFees_Exceeds25PercentLimit() public {
        console.log("--- BEFORE-Trigger State ---");
        // Read initial total fee from storage
        bytes32 totalFeeSlot = bytes32(TOTAL_FEE_SLOT);
        uint256 totalFeeBefore = uint256(vm.load(address(token), totalFeeSlot));
        uint256 feeDenominatorBefore = token.feeDenominator();
        uint256 feePercentBefore = (totalFeeBefore * 100) / feeDenominatorBefore;
        
        console.log("Total Fee BEFORE: %s", totalFeeBefore);
        console.log("Fee Denominator BEFORE: %s", feeDenominatorBefore);
        console.log("Fee Percentage BEFORE: %s%%", feePercentBefore);

        console.log("--- Trigger setFees ---");
        // Setup fees exceeding 25% limit (7+7+6+6=26%)
        uint256 liquidityFee = 7;
        uint256 buybackFee = 7;
        uint256 reflectionFee = 6;
        uint256 marketingFee = 6;
        uint256 feeDenominator = 100;
        
        console.log("Setting fees to: Liq=%s%%, Buy=%s%%, Ref=%s%%, Mar=%s%% (Denominator=%s)",
            liquidityFee, buybackFee, reflectionFee, marketingFee, feeDenominator);

        // Set fees with owner account
        vm.startPrank(owner);
        token.setFees(
            liquidityFee,
            buybackFee,
            reflectionFee,
            marketingFee,
            feeDenominator
        );
        vm.stopPrank();

        console.log("--- AFTER-Trigger State ---");
        // Read updated total fee from storage
        uint256 totalFeeAfter = uint256(vm.load(address(token), totalFeeSlot));
        uint256 feeDenominatorAfter = token.feeDenominator();
        uint256 feePercentAfter = (totalFeeAfter * 100) / feeDenominatorAfter;
        
        console.log("Total Fee AFTER: %s", totalFeeAfter);
        console.log("Fee Denominator AFTER: %s", feeDenominatorAfter);
        console.log("Fee Percentage AFTER: %s%%", feePercentAfter);

        // Vulnerability verification
        bool exceedsLimit = feePercentAfter > 25;
        console.log("Verdict: Total fees %s 25%% limit", 
                   exceedsLimit ? "EXCEED" : "within");

        // Final vulnerability determination
        if (exceedsLimit) {
            console.log("Vulnerability Exists: Total fees (%s%%) exceed maximum allowed 25%%", feePercentAfter);
        } else {
            console.log("Vulnerability not Exist: Total fees (%s%%) are within allowed limit", feePercentAfter);
        }
    }
}