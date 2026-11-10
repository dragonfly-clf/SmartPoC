3. Operation between different time units
   block.timestamp may be bigger than startTime plus initialLock in
   seconds, but initialLock is given in days. This could lead to
   unexpected unlocking of funds or reverting the transaction according
   to internal reasons.
   Contract: FidoMeta.sol
   Functions: unlock
   Recommendation: multiply initialLock by 1 days.
   Status: Fixed (Revised Commit: 66f43e8)
  