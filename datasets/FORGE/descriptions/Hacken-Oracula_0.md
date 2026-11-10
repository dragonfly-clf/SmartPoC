High
   1. Transfer Receives Fees.
   In the _transfer() function fees are deducted from the amount. This
   causes the receiver to get less than desired amount every time. Also
   it is impossible to predict fees.
   Contracts:Oracula.sol
   Functions: _transfer(address _from, address _to, uint256 _amount)
   Recommendation: Transfer and transferFrom should not take a fee.
  