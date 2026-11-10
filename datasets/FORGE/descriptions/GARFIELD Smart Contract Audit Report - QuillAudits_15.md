13. Missing Range Check for Input Variable

 Line Code

 1104 function setTaxFeePercent(uint256 taxFee) external onlyOwner() {
     _taxFee = taxFee;  }

 1108 function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {
     _liquidityFee = liquidityFee;  }

 1311 function setMaxTxPercent(uint256 maxTxPercent) public onlyOwner() {
     _maxTxAmount = _tTotal.mul(maxTxPercent).div(10000);  }

 Description The role can set the following state variables arbitrary large or small causing potential risks in fees and anti whale :   _taxFee   _liquidityFee   _maxTxAmount

 Remediation We recommend setting ranges and check the following input variables:   taxFee   liquidityFee   maxTxPercent

 Status: Closed The Garfield team made some fixes based on our recommendations. We address below the fixes introduced up to commit 196d46bc7e4cfce93a162dc1970417d1c11eb891

 