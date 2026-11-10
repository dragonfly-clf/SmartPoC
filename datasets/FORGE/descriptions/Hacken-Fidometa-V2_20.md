8. Violation of ERC-20 standard
  transferFrom should be possible if the amount is allowed by the owner
  of the assets. If a user tries to transfer all the allowance size, it
  fails.
  Contract: FidoMeta.sol
  Function: transferFrom
  Recommendation: fix this case.
  Status: Acknowledged
