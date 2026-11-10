#### Low level severity issues

###### 6. Missing Range Check for Input Variable

 Description The owner can set the following state variables arbitrary large or small causing potential risks in fees and anti whale :   _buyBackMaxTimeForHistories   _buyBackDivisor   _buyBackTimeInterval   _intervalMinutesForSwap   _taxFee   _buyTaxFee   _buyLiquidityFee   _sellTaxFee   _sellLiquidityFee   _liquidityFee   buyBackSellLimit   _maxTxAmount    marketingDivisor   minimumTokensBeforeSwap
 Remediation We recommend setting ranges and check the above input variables.

 Status: Acknowledged by the Auditee

 7. Missing zero address validation

 Line Code

 1112-1114 function setMarketingAddress(address _marketingAddress) external onlyOwner {   marketingAddress = payable(_marketingAddress); }

 Description When updating the marketing address, it should be checked for zero address. Otherwise, tokens/ETH sent to the zero address may be burnt forever.

 0510


-----

|Presence of|unused code|
|---|---|
|Line|Code|
|499|bool public _isEnabledBuyBackAndBurn = true;|
|501 event RewardLiquidityProviders(uint256 tokenAmount);||
|505-509 event SwapAndLiquify( uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity );||
|850-863 function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private { // Approve token transfer to cover all possible scenarios _approve(address(this), address(uniswapV2Router), tokenAmount); // Add the liquidity uniswapV2Router.addLiquidityETH{value: ethAmount}( address(this), tokenAmount, 0, // Slippage is unavoidable 0, // Slippage is unavoidable owner(), block.timestamp ); }||


###### Remediation Use a require statement to check for zero address when updating the marketing address.

 Status: Acknowledged by the Auditee

