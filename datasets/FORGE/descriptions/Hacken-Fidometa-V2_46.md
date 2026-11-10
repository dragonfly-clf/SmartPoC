25. Unnecessary checks
  Any unnecessary code should be removed in order to save Gas. Checks
  for each fee separately are not needed because the check for the sum
  is stronger.
  Contract: FidoMeta.sol
  Function: setCharges
  Recommendation: remove unnecessary code.
  Status: Acknowledged
