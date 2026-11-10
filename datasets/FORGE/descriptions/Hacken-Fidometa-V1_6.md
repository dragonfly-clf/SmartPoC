1. A new vesting period may not be created
  locks mapping is not cleared on finishing of the vesting period, so
  the owner will not be able to set new vesting for the same user.
  Contract: FidoMeta.sol
  Functions: transferWithLock, unlock
  Recommendation: delete locks’ item on the last unlocking.
  Status: Fixed (Revised Commit: 66f43e8)
