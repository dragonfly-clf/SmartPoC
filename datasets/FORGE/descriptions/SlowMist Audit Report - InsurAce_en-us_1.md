#### 4.3.1.1 Reordering attack risk

###### When the owner calls preparePaymentForPayout, it will go to uniswap to calculate the required

 amountIn, and then perform the swap operation according to the amountIn. There is a risk of

 rearrangement attacks that may cause losses in the InsurAce pool. It is recommended to check the

 slippage of swap.

 Reference：

 https://www.odaily.com/post/5162888

 https://medium.com/coinmonks/demystify-the-dark-forest-on-ethereum-sandwich-attacks-5a3ae

 c9fa33e

  contracts/pool/StakersPool.sol


**function claimPayout(**


address _fromToken,


address _paymentToken,


uint256 _settleAmtPT,


address _claimTo,


uint256 _claimId


) external override allowedCaller {


require(_fromToken == poolToken, "CP:1");


###### 23


-----

**if (_settleAmtPT == 0) {**


**return;**


}


uint256 temp = _getTokenforExactPaymentToken(_fromToken, _paymentToken, _settleAmtPT);


uint256 amountInMax = Math.min(stakedAmount, temp.mul(11).div(10));


uint256 convertOut = _convertTokenforExactPaymentToken(_fromToken, _paymentToken, _settleAmtPT, amountInMax);


stakedAmount = stakedAmount.sub(convertOut);


claimPayouts.push(convertOut);


claimPayoutsClaimId.push(_claimId);


_transferTokenTo(_paymentToken, _settleAmtPT, _claimTo, _claimId);


}


**function _convertTokenforExactPaymentToken(**


address _tokenFrom,


address _tokenTo,


uint256 _amountOut,


uint256 _amountInMax


) private returns (uint256) {


require(_tokenFrom != _tokenTo, "CT2EPT:1");


address[] memory path = new address[](2);


uint256[] memory ret;


**if (_tokenFrom == Constant.ETHTOKENADDRESS) {**


path[0] = uniswapRouter.WETH();


path[1] = _tokenTo;


ret = uniswapRouter.swapETHForExactTokens{value: _amountInMax}(


_amountOut,


path,


address(this),


block.timestamp + 120 // solhint-disable-line not-rely-on-time


);


**return ret[0];**


}


**if (_tokenTo == Constant.ETHTOKENADDRESS) {**


path[0] = _tokenFrom;


path[1] = uniswapRouter.WETH();


IERC20Upgradeable(path[0]).approve(Constant.UNISWAPV2_ROUTER_ADDRESS, _amountInMax);


ret = uniswapRouter.swapTokensForExactETH(


_amountOut,


_amountInMax,


path,


###### 24


-----

address(this),


block.timestamp + 120 // solhint-disable-line not-rely-on-time


);


**return ret[0];**


}


path[0] = _tokenFrom;


path[1] = _tokenTo;


IERC20Upgradeable(path[0]).approve(Constant.UNISWAPV2_ROUTER_ADDRESS, _amountInMax);


ret = uniswapRouter.swapTokensForExactTokens(


_amountOut,


_amountInMax,


path,


address(this),


block.timestamp + 120 // solhint-disable-line not-rely-on-time


);


**return ret[0];**


}


######  contracts/pool/StakersPool.sol


**function _getTokenforExactPaymentToken(**


address _tokenFrom,


address _tokenTo,


uint256 _amount


) private view returns (uint256) {


**if (_tokenFrom == _tokenTo) {**


**return _amount;**


}


address[] memory path = new address[](2);


**if (_tokenFrom == Constant.ETHTOKENADDRESS) {**


path[0] = uniswapRouter.WETH();


} else {


path[0] = _tokenFrom;


}


**if (_tokenTo == Constant.ETHTOKENADDRESS) {**


path[1] = uniswapRouter.WETH();


} else {


path[1] = _tokenTo;


}


###### 25


-----

uint256[] memory ret = uniswapRouter.getAmountsIn(_amount, path);


**return ret[0];**


}


###### Fix Status: The issues has been fixed.

