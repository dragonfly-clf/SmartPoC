2. Excluding from receiving rewards logic is corrupted
   After excluding the user from rewards (excludeFromReward), the user
   should not get part of the community charge (and the user sees it
   so). However, his reflection balance updates along with his prime
   balance, and on including this user back (includeInReward), his
   balance is updated according to reflection tokens (_rOwned), and all
   hidden community rewards will be received.
   Contract: FidoMeta.sol
   Recommendation: review and fix the logic.
   Status: Fixed (Revised Commit: 66f43e8)
  