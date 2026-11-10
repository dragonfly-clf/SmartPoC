### High severity issues

###### 1. Transfer is from msg.sender instead of contract balance to
 _buyBackAddress

 Line Code

 1749 function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {   // split the contract balance into halves   uint256 half = contractTokenBalance.mul(4000).div(10000);   uint256 rest = contractTokenBalance.sub(half).sub(half);

   transfer(_buyBackAddress, rest);

 Description In the function swapAndLiquify(), a call to the function transfer() is done to make a transfer from the contract address to the _buyBackAddress. But as the msg.sender for this transfer call will be the user doing the transaction, the amount will be deducted from that user’s account.

 If swapAndLiquify is ever executed then a huge amount of that user’s tokens will be sent to the buyback Address. Otherwise there is a high chance that all the transactions will get reverted if contract balance > numTokensSellToAddToLiquidity, because then swapAndLiquify() will be called and the user won’t have the balance to transfer 20% of the numTokensSellToAddToLiquidity to the buyback Address.

 Remediation Use the internal _transfer() function to do the transfer from contract balance.

 Status: Fixed In the Version 2, _transfer() function is used.

 05


-----

|Infinite loop|Col2|
|---|---|
|Line|Code|
|1895-1917 function lock( bytes32 _reason, uint256 _amount, uint256 _time ) public override onlyWhitelistAdmin returns (bool) { uint256 validUntil = block.timestamp.add(_time); // If tokens are already locked, then functions extendLock or // increaseLockAmount should be used to make any changes require(tokensLocked(msg.sender, _reason) == 0, "ERC1132: Already locked"); require(_amount != 0, "ERC1132: Zero Amount"); if (locked[msg.sender][_reason].amount == 0) lockReason[msg.sender].push(_reason); transfer(address(this), _amount); locked[msg.sender][_reason] = LockToken(_amount, validUntil, false); emit Locked(msg.sender, _reason, _amount, validUntil); return true; }||
|1927-1949 function transferFromWithLock( address _from, address _to, bytes32 _reason, uint256 _amount, uint256 _time ) public returns (bool) { ... ... ... _lockedAmount.add(_amount); emit Locked(_to, _reason, _lockedAmount, validUntil); return true; }||
|2075-2090 function unlock(address _of) public override returns (uint256 unlockableTokens) { ... ... if (unlockableTokens > 0) { uint256 beforeBalance = balanceOf(_of); this.transfer(_of, unlockableTokens); _lockedAmount.sub((balanceOf(_of).sub(beforeBalance))); }||


###### 2. Infinite loop

 Line Code

 1895-1917 function lock(
   bytes32 _reason,   uint256 _amount,   uint256 _time  ) public override onlyWhitelistAdmin returns (bool) {   uint256 validUntil = block.timestamp.add(_time);
   // If tokens are already locked, then functions extendLock or   // increaseLockAmount should be used to make any changes   require(tokensLocked(msg.sender, _reason) == 0, "ERC1132: Already locked");   require(_amount != 0, "ERC1132: Zero Amount");
   if (locked[msg.sender][_reason].amount == 0)    lockReason[msg.sender].push(_reason);
   transfer(address(this), _amount);
   locked[msg.sender][_reason] = LockToken(_amount, validUntil, false);     emit Locked(msg.sender, _reason, _amount, validUntil);   return true;  }

 1927-1949  function transferFromWithLock(
   address _from,   address _to,   bytes32 _reason,   uint256 _amount,   uint256 _time  ) public returns (bool) {   ...   ...   ...    _lockedAmount.add(_amount);
   emit Locked(_to, _reason, _lockedAmount, validUntil);   return true;  }

 2075-2090 function unlock(address _of)
   public   override   returns (uint256 unlockableTokens)  {   ...   ...    if (unlockableTokens > 0) {    uint256 beforeBalance = balanceOf(_of);    this.transfer(_of, unlockableTokens);    _lockedAmount.sub((balanceOf(_of).sub(beforeBalance)));   }

 0506


-----

###### Description _lockedAmount state variable is used to keep track of the amount of tokens locked in the contract balance. But in the lock() function, it's not updated after some tokens are locked. Due to this, there can be an underflow, while unlocking.

 In the transferFromWithLock() function, the statement  _lockedAmount.add(_amount); does not update the state variable. 

 In the unlock() function, the statement  _lockedAmount.sub((balanceOf(_of).sub(beforeBalance))); does not update the variable.

 In the increaseLockAmount() function, no statement to update the _lockedAmount was found.

 Remediation Update the _lockedAmount variable in the lock(), transferFromWithLock(),increaseLockAmount() and unlock() function.

 Status: Fixed In the Version 2, _lockedAmount variable was updated in all the above- mentioned functions.

