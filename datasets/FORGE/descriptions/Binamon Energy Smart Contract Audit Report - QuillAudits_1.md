#### Medium severity issues

###### 2. Approve Race

   function approve(address delegate, uint256 numTokens) public override returns (bool) {     allowed[msg.sender][delegate] = numTokens;     emit Approval(msg.sender, delegate, numTokens);     return true;   }

 Description The standard ERC20 implementation contains a widely-known racing condition in its approve function, wherein a spender is able to witness the token owner broadcast a transaction altering their approval and quickly sign and broadcast a transaction using transferFrom to move the current approved amount from the owner’s balance to the spender. If the spender’s transaction is validated before the owner’s, the spender will be able to get both approval amounts of both transactions.
 Remediation

  function approve(address delegate, uint256 _currentValue ,uint256 numTokens) public override returns (bool) {     if(_currentValue == allowed[msg.sender][delegate])      {       allowed[msg.sender][delegate] = numTokens;       emit Approval(msg.sender, delegate, numTokens);       return true;     }     else return false;   }

 Status: Acknowledged by the Auditee

