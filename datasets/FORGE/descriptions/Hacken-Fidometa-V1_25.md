4. Violation of IERC-20 standard
  According to the IERC-20 standard, the functions should be external
  to save Gas.
  Contract: FidoMeta.sol
  Function: transfer, allowance, approve, transferFrom
  Recommendation: these functions should be declared as external.
  Status: Fixed (Revised Commit: 66f43e8)
