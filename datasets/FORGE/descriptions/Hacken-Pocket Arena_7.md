2. A public function that could be declared external.
  public functions that are never called by the contract should be
  declared external to save gas.
  Contracts: POC_ERC20.sol, POC_BEP20.sol
  Functions: pegin_run, remove_arr_pegin_reserve, transferFrom,
  staff_list, staff_del, staff_quota_add, staff_quota_minus,
  _fee_rate_get, fee_income, unlocked_POC_total,
  unlocked_POC_total_add, unlocked_POC_total_minus, pegout_submit,
  pegout_submit_list, pegout_submit_complete, pegout_submit_delete,
  pegout_submit_cancel, pegin_reserve, pegin_reserve_cancel,
  pegin_reserve_list, pegin_reserve_list, pegin_run, pegout_run,
  remove_arr_pegout_reserve, transferFrom, staff_list, staff_del,
  staff_quota_add, staff_quota_minus, _fee_rate_get, locked_POC_total,
  locked_POC_total_add, locked_POC_total_minus, pegin_submit,
  pegin_submit_list, pegin_submit_complete, pegin_submit_delete,
  pegin_submit_cancel, pegout_reserve, pegout_reserve_cancel,
  pegout_reserve_list, pegout_reserve_list, pegout_run
  Recommendation: Use the external attribute for functions never called
  from the contract.
  Status: fixed
