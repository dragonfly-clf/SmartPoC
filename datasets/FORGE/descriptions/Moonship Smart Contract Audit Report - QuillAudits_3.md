#### Informational

###### 8. Variable Typo

 Line Code

 933 uint256 tokensIntoLiqudity

 Description: There is a typo in tokensIntoLiqudity.
 Remediation: We recommend correcting and changing tokensIntoLiqudity to tokensIntoLiquidity.

 Status: Acknowledged by the Auditee

 9.Missing Events for Significant Transactions

 Line Code

 1092 function excludeFromFee(address account) public onlyOwner {
     _isExcludedFromFee[account] = true;   }

 1906 function includeInFee(address account) public onlyOwner {
     _isExcludedFromFee[account] = false;   }

 1100 function setTaxFeePercent(uint256 taxFee) external onlyOwner() {
     _taxFee = taxFee;   }

 1104 function setLiquidityFeePercent(uint256 liquidityFee) external
 onlyOwner() {     _liquidityFee = liquidityFee;   }

 0510