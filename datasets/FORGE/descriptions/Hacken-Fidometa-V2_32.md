11. Template code
  It is better to create a modifier to disable necessary changes.
  Contract: FidoMeta.sol
  Function: removeEcosysFee, removeSurcharge1, removeSurcharge2,
  removeSurcharge3, removeCommunityCharge, restoreCommunityCharge,
  restoreEcosysFee, restoreSurcharge1, restoreSurcharge2,
  restoreSurcharge3
  Recommendation: remove these functions and implement a modifier that
  unites all the logic.
  Status: Fixed (Revised Commit: 66f43e8)
