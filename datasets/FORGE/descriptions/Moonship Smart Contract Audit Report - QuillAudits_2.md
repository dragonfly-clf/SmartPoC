#### Low level severity issues

###### 5. Tautology or Contradiction Issue

 Line Code

 1340 require(balanceOf(msg.sender) >= 0, 'Error: must own MRAT to claim reward');

 Description: balanceOf(msg.sender) >= 0 is true even if the balance of the msg.sender is 0. This comparison is a tautology that will waste gas during the execution.
 Remediation: Fix the incorrect comparison by changing the value type or the comparison.

 Status: Acknowledged by the Auditee

 6.Redundant Code

 Line Code

 1245 else if (!_isExcluded[sender] && !_isExcluded[recipient])

 Description: When the contract enters the branch else if (!_isExcluded[sender] && ! _isExcluded[recipient]) or else, the contract will execute the same piece of code _transferStandard(sender, recipient, amount);
 Remediation: We recommend removing the following code

 Status: Acknowledged by the Auditee

 0508


-----

|Line|Code|
|---|---|
|1100 function setTaxFeePercent(uint256 taxFee) external onlyOwner() { _taxFee = taxFee; }||
|1104 function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() { _liquidityFee = liquidityFee; }||
|1307 function setMaxTxPercent(uint256 maxTxPercent) public onlyOwner() { _maxTxAmount = _tTotal.mul(maxTxPercent).div(10000); }||


###### 7. Missing Range Check for Input Variable

 Line Code

 1100 function setTaxFeePercent(uint256 taxFee) external onlyOwner() {
     _taxFee = taxFee;   }

 1104 function setLiquidityFeePercent(uint256 liquidityFee) external
 onlyOwner() {     _liquidityFee = liquidityFee;   }

 1307 function setMaxTxPercent(uint256 maxTxPercent) public onlyOwner() {
     _maxTxAmount = _tTotal.mul(maxTxPercent).div(10000);   }

 Description: The role can set the following state variables arbitrary large or small causing potential risks in fees and anti whale :    _taxFee    _liquidityFee    _maxTxAmount
 Remediation: We recommend setting ranges and check the following input variables:    taxFee     liquidityFee    maxTxPercent

 Status: Acknowledged by the Auditee

 0509


-----

|Line|Code|
|---|---|
|933|uint256 tokensIntoLiqudity|

|Line|Code|
|---|---|
|1092 function excludeFromFee(address account) public onlyOwner { _isExcludedFromFee[account] = true; }||
|1906 function includeInFee(address account) public onlyOwner { _isExcludedFromFee[account] = false; }||
|1100 function setTaxFeePercent(uint256 taxFee) external onlyOwner() { _taxFee = taxFee; }||
|1104 function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() { _liquidityFee = liquidityFee; }||


