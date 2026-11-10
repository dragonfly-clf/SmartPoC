token holder.
   Contracts:POC_ERC20.sol, POC_BEP20.sol
   Functions: pegin_submit, pegout_submit
   Arrays ERC20POC.arr_pegin_submit and BEP20POC.pegout_submit could be
   filled by the malicious token holder using the methods listed above.
   Every transaction will cost him/her a fixed amount of gas and the
   minimal amount of tokens. On the other hand, increasing size of that
   arrays will drastically increase the gas cost of methods
   pegout_submit_complete, pegout_submit_delete, pegout_submit_cancel,
   pegin_submit_complete, pegin_submit_delete, pegin_submit_cancel up to
   the gas limit of the block that resulting in permanent inoperability
   of these methods.
   Recommendation: rewrite contracts to stop using regular arrays of
   unpredictable size, use mappings instead.
   Status: fixed
  