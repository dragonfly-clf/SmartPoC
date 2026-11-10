L09. Undocumented Literals
  The constructor() sets 10 billion tokens to mint as
  10*(10**9)*10**18.
  It is advised to use named constants instead of literals when
  important functionality is performed (e.g. MINT_AMOUNT). The function
  decimals() can also be used instead of 10**18.
  Path:
  ./contracts/ByTradeToken: constructor()
  Recommendation: Consider replacing literals with named constants in
  the contract.
  Status: Reported
