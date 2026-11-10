13. Functions that can be declared as external
  To save Gas, public functions that are never called in the contract
  should be declared as external.
  Contract: FidoMeta.sol
  Function: setCommunityCharge, setEcoSysFee, setSurcharge1,
  setSurcharge2, setSurcharge3, setEcoSysWallet, setSurcharge_1_Wallet,
  setSurcharge_2_Wallet, setSurcharge_3_Wallet, burn, mint, name,
  symbol, decimals, increaseAllowance, decreaseAllowance,
  excludeFromReward, excludeFromCommunityCharge,
  includeInCommunityCharge, excludedFromEcoSysFee, includeInEcoSysFee,
  Recommendation: aforementioned should be declared as external.
  Status: Fixed (Revised Commit: 66f43e8)
