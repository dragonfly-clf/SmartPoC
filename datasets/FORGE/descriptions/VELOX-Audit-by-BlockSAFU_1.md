####   High-Risk

 1 high-risk code issue found

 Must be fixed, and will bring problem.

 The owner can set the selling fee up to 100%

function setTaxFeePercent(uint256 taxFee) external onlyOwner() {
_taxFee = taxFee;
}

function setDevFeePercent(uint256 devFee) external onlyOwner() {
_devFee = devFee;
}

function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {
_liquidityFee = liquidityFee;
}

function setMaxTxPercent(uint256 maxTxPercent) public onlyOwner {
_maxTxAmount = maxTxPercent * 10 ** _decimals;
}

The owner contract can be modified Tax Fee, Dev Fee, Liquidity, or MaxTxPercent with the
maximum amount

####   Critical-Risk 0 critical-risk code issues found

 Must be fixed, and will bring honeypot.