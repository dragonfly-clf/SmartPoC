8. Similar functions
  Functions that do mostly the same things may be united.
  Contract: FidoMeta.sol
  Function: excludeFromCommunityCharge, includeInCommunityCharge,
  excludedFromEcoSysFee, includeInEcoSysFee, excludedFromSurcharge1,
  includeInSurcharge1, excludedFromSurcharge2, includeInSurcharge2,
  excludedFromSurcharge3, includeInSurcharge3
  Recommendation: unite these functions in one that sets all
  includes/excludes.
  Status: Fixed (Revised Commit: 66f43e8)
