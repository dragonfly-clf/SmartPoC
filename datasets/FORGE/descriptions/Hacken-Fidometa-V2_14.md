2. Possible Gas exceeding
  The contract can exceed the gas limit in long cycles.
  Contract: FidoMeta.sol
  Functions: includeInReward
  Recommendation: update logic to prevent situations when
  _excludedFromReward is too long.
  Status: Fixed (Revised Commit: 66f43e8)
