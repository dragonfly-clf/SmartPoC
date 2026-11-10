2. Token validity

 The contract tries to restrict the usable tokens to only ERC20 tokens but their implementation under the hood can be quite different from what is expected from standard tokens. FeeOnTransfer tokens, and rebase tokens can drastically reduce the expected number of tokens deposited into the vault and the expected amount to be available for withdrawal.

 Recommendation

 Consider ways to handle tokens like these or have a list of approved tokens to be used in this project.

 Status

 Partially Resolved

 Auditor’s Remark - The client has implemented the SafeERC20 token wrapper to reduce the landscape of risk which custom ERC20 tokens introduce. To accommodate for future possible tokens to be added, no token list is used.


-----

###### 