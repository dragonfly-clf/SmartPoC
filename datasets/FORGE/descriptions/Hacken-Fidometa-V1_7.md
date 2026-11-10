2. No checks to prevent percentage overflow
  Fees may become more than 100%. Every fee could be up to 100%, and
  their sum is 500%.
  This could lead to reverting of all transactions.
  Contract: FidoMeta.sol
  Function: setCommunityCharge, setEcoSysFee, setSurcharge1,
  setSurcharge2, setSurcharge3
  Recommendation: implement checks to prevent the scenario, validate
  that sum of all fees does not exceed 100%.
  Status: Fixed (Revised Commit: 7bb7d6d)
