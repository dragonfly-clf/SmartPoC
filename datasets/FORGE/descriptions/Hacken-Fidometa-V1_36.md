15. Modification of well-known contract
  Imported or copy-pasted contracts (like SafeMath, Context, Ownable,
  etc.) should not be modified to keep the code clear. Ownable contract
  is modified with a _lockTime variable that is never used.
  Contract: FidoMeta.sol
  Recommendation: remove unused variable.
  Status: Fixed (Revised Commit: 7bb7d6d)
