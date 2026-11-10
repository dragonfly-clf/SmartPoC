18. Functions that can be declared as external
  To save Gas, public functions that are never called in the contract
  should be declared as external.
  Contract: FidoMeta.sol
  Function: excludeFromReward
  Recommendation: use the external attribute for functions never called
  from the contract.
  Status: Fixed (Revised Commit: 7bb7d6d)
