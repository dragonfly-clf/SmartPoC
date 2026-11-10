4. Integer Underflow
  If a user unlocks vesting firstly in the first four months and then
  in the sixth month or later, the transaction will be reverted due to
  underflow.
  This may lead to total unavailability to unlock vestings.

```

-----

```
  Contract: FidoMeta.sol
  Functions: unlock
  Recommendation: rewrite the code avoiding recalculations, and
  structure actions sequentially, processing this case.
  Status: Fixed (Revised Commit: 7bb7d6d)
