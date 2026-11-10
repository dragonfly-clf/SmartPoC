4. Significant impact on market price
   The functions change the balances of all users at one moment. This
   could be used for changing market price significantly, predicting
   exchange rates, and as a result, looting untrained users.
   This may lead to total user discontent.
   Contract: FidoMeta.sol
   Functions: burn, mint

```

-----

```
  Recommendation: minting and burning functionality should change the
  balance of one user, provide this functionality or remove the
  functions.
  Status: Fixed (Revised Commit: 7bb7d6d)
 