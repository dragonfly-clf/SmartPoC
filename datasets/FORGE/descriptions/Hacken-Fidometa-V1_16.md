4. Initial minting event skipped
  In the constructor, if all tokens are assigned to the owner, the
  Transfer event should be emitted.
  Contract: FidoMeta.sol
  Recommendation: emit the event.
  Status: Fixed (Revised Commit: 7bb7d6d)
