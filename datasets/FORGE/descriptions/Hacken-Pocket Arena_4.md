Potential loss of users’ submits and data inconsistency.
   When several users call methods within one block, only the last one
   will create order because the key for storing data in arr_pegout_submit
   and arr_pegin_submit generate only based on block.timestamp
   Contracts: POC_ERC20.sol, POC_BEP20.sol
   Functions: pegin_submit, pegout_submit
   Recommendation: Also use unique parameters to generate storage index,
   for example, msg.sender
   Status: fixed
 