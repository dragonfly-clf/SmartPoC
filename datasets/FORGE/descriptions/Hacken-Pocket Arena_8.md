3. Boolean equality
  Boolean constants can be used directly and do not need to be compared
  to true or false.
  Contracts: POC_ERC20.sol, POC_BEP20.sol
  Functions: transfer, transferFrom, staff_add, staff_quota_add,
  pegin_reserve, pegout_reserve
  Recommendation: remove the equality to the boolean constant.
  Status: fixed
