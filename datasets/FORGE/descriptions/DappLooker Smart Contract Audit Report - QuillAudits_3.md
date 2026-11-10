4. Only owner can make withdrawals

 The current logic of this contract allows only the owner to withdraw deposited tokens. This means User A can make a deposit but would never be able to withdraw their deposited tokens unless they were the deployers of the contract and/or the caller of the initialize function.

 Recommendation

 Update the logic to map tokens deposited to their owners and give withdrawal allocation to the token owners specifically or explicitly state the current functionality in the contract docs.

 Status

 Resolved

 Dapplooker Team’s Comment: We don't need to keep track which user have deposited and for what duration, we are simple keeping the transaction hash as proof that user have deposited and verifiying the increased amount for that particular token (which we know) by ERC20 token balance of function where we are looking for balance of our contract. We are looking at contract, as an on chain wallet which will be have the token amount and as an owner we can withdraw to our wallet whenever required.
 We didn't designed it like having a separate map to keep user wallets to transferred amount details.
 Auditor’s Remark - This tallies with the business logic as described by the client.

 Low Severity Issues

 No issues were found


-----

###### Informational Issues

 