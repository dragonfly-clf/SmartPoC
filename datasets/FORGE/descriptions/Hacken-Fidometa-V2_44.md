23. Unnecessary code
  Any unnecessary code should be removed in order to save Gas. There
  could be only 4 types of transfer, so the else case is not needed.
  Contract: FidoMeta.sol
  Function: _tokenTransfer
  Recommendation: remove unnecessary code.
  Status: Acknowledged
