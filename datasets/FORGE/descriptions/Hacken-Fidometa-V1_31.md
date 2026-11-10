10. Template code
  The functions do not compose calculations and are used only in one
  place, so code separation is useless.
  Contract: FidoMeta.sol
  Function: calculateCommunityCharge, calculateSurcharge1,
  calculateSurcharge2
  Recommendation: the functions could be deleted or replaced with a
  function that receives the fee and amount and returns the calculated
  value.

```

-----

```
  Status: Fixed (Revised Commit: 66f43e8)
