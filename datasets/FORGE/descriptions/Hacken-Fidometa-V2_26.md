5. Unused functions
  Unused code overloads the code and takes additional Gas for
  deploying. It is better to use the public keyword in the struct
  definition for automatic generation of view methods.
  Contract: FidoMeta.sol
  Functions: isExcludedFromCommunityCharge, isExcludedFromEcoSysFee,
  isExcludedFromSurcharge1, isExcludedFromSurcharge2,
  isExcludedFromSurcharge3, viewSurcharge_1_Wallet,
  viewSurcharge_2_Wallet, viewSurcharge_3_Wallet, viewEcoSysWallet,
  isExcludedFromReward, totalCommunityCharge, name, symbol, decimals
  Recommendation: remove these functions and declare corresponding
  structs as public.
  Status: Fixed (Revised Commit: 66f43e8)
