1. Inconsistency with fees
  While in the comments it says: “transfer 7% to token manager; transfer
  10% to token creator; transfer 83% to token owner” it is actually
  doesn’t do what it said. 

```

-----

```
   The function, actually, accepts the “percents” values
  as its arguments and those arguments are never
  checked.
  Using this function anyone buying a token could specify any percents
  they want.
  For example, anyone could call the function with m=0, r=0, o=0; in this
  case, everyone: manager, creator and owner will receive 0 amount and
  the attacker will receive this token for free.
  Contracts: Colexion
  Function: purchaseToken
  Recommendation: Please make sure that fees are checked correctly.
  Status: Fixed
  