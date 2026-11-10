#### Low level severity issues

###### 4. Locks cannot be extended or increased in amount

 Line Code

 1926-1948  function transferFromWithLock(   address _from,   address _to,   bytes32 _reason,   uint256 _amount,   uint256 _time  ) public returns (bool) {   uint256 validUntil = block.timestamp.add(_time);   require(isWhitelistAdmin(_from), "ERC1132: Not whitelisted");   require(tokensLocked(_to, _reason) == 0, "ERC1132: Already locked");   require(_amount != 0, "ERC1132: Zero Amount");
   if (locked[_to][_reason].amount == 0) lockReason[_to].push(_reason);
   transferFrom(_from, address(this), _amount);
   locked[_to][_reason] = LockToken(_amount, validUntil, false);   _lockedAmount.add(_amount);
   emit Locked(_to, _reason, _amount, validUntil);   return true;  }

 0508


-----

|Line|Code|
|---|---|
|1532 function setTaxFeePercent(uint256 taxFee) external onlyOwner() { _taxFee = taxFee; }||
|1536 function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() { _liquidityFee = liquidityFee; }||
|1540 function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() { _maxTxAmount = _tTotal.mul(maxTxPercent).div(10**2); }||


###### Description The token locks which were created with transferFromWithLock(), can neither be extended nor be increased in amount. This is because the tokens are locked for the ‘to’ address and it is not checked for isWhitelistAdmin. But to access the extendLock() or increaseLockAmount() function ‘to’ address should be isWhitelistAdmin == true.

 Remediation Check the ‘to’ address for isWhitelistAdmin

 Status: Acknowledged by the Auditee Comments from Auditee: “For transferFromWithLock(), _to can be not whitelisted as admin. Moreover, we don't need to extend lock time or increase the amount after transferFromWithLock is executed.”

 5. Critical operation lacks event log

 Line Code

 function setTaxFeePercent(uint256 taxFee) external onlyOwner() {
 1532

     _taxFee = taxFee;

   }

 function setLiquidityFeePercent(uint256 liquidityFee) external
 1536

 onlyOwner() {

     _liquidityFee = liquidityFee;

   }

 function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner()
 1540

 { _maxTxAmount = _tTotal.mul(maxTxPercent).div(10**2); }

 Description The role can set the following state variables arbitrary large or small causing potential risks in fees and anti whale :
 - _taxFee
 - _liquidityFee
 - _maxTxAmount

 0509


-----

|Line|Code|
|---|---|
|1293|uint256 tokensIntoLiqudity|

|Line|Code|
|---|---|
|1279|bool inSwapAndLiquify;|


###### Remediation We recommend setting ranges and check the following input variables:  - taxFee  - liquidityFee  - maxTxPercent

 Status: Fixed In the Version 2, the input variables were checked before updating the state.

