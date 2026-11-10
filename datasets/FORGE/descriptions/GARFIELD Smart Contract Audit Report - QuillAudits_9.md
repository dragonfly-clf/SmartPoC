8. Lack of event emissions

 Line Code

 1096 function excludeFromFee(address account) public onlyOwner {
     _isExcludedFromFee[account] = true;  }

 1100 function includeInFee(address account) public onlyOwner {
     _isExcludedFromFee[account] = false;  }

 1104 function setTaxFeePercent(uint256 taxFee) external onlyOwner() {
     _taxFee = taxFee;  }

 1108 function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {
     _liquidityFee = liquidityFee;  }

 1311 function setMaxTxPercent(uint256 maxTxPercent) public onlyOwner() {
     _maxTxAmount = _tTotal.mul(maxTxPercent).div(10000);  }

 1315 function setExcludeFromMaxTx(address _address, bool value) public
 onlyOwner {     _isExcludedFromMaxTx[_address] = value;  }

 0510


-----

###### Description The missing event makes it difficult to track off-chain liquidity fee changes. An event should be emitted for significant transactions calling the following functions:

   setLiquidityFeePercent   setTaxFeePercent   includeInFee   excludeFromFee   setMaxTxPercent   setExcludeFromMaxTx

 Remediation We recommend emitting an event to log the update of the following variables:

   _maxTxAmount   _isExcludedFromMaxTx   _liquidityFee   _taxFee   _isExcludedFromFee

 Status: Closed The Garfield team made some fixes based on our recommendations. We address below the fixes introduced up to commit a970422b652cc9bc66ddbfd54741e26428b4b42f

 