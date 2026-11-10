14. Requires that would never revert transaction
  uint256 will always be >= 0, the requires are useless
  Contract: FidoMeta.sol
  Functions: transferWithLock
  Recommendation: review what the requirements should prevent and fix
  them.

```

-----

```
  Status: Fixed (Revised Commit: 7bb7d6d)
