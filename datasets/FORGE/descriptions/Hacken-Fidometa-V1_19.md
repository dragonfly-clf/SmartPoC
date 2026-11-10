7. Possible Gas exceeding
  The contract can exceed the gas limit in long cycles.
  As accounts could be only excluded, it is better to update the logic
  of rates calculation and separate excluded accounts from r-space. In
  such a way, a significant amount of Gas could be saved at
  recalculation of total supply and actual rates.
  Contract: FidoMeta.sol
  Function: _getCurrentSupply
  Recommendation: update logic to prevent situations when _excluded
  array is too long, keep actual information about supply for not
  recalculating it each time.
  Status: Acknowledged
