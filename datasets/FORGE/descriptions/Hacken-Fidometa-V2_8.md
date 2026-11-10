3. User balance may exceed the total supply
  If the owner excludes himself from rewards and then burns all tokens,
  the total supply will be lower than the sum of user balances.
  This may lead to wrong rates calculation and unexpected behavior of
  taking charges logic.
  Contract: FidoMeta.sol
  Functions: burn
  Recommendation: check this case and fix the corresponding logic.
  Status: Fixed (Revised Commit: 7bb7d6d)
