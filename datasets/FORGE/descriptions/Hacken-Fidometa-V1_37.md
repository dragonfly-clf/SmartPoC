16. Local variable shadowing
  Local variable shadowing may lead to unexpected code behavior in
  future development.
  Contract: FidoMeta.sol
  Functions: _approve:(owner)
  Contract: BreederDaoTokenLockWallet.sol
  Recommendation: rename the local variables that shadow other
  components.
  Status: Fixed (Revised Commit: 7bb7d6d)
