#### STVI - Swap Token Variable Inconsistency


#### Description


The `manualSwap` function allows users to trigger a manual swap of tokens for ETH.


However, the contract does not reset or decrease the `tokensForDev` and


`tokensForMarketing` variables after the manual swap. This could result in an


inconsistency between the actual contract balance and the amounts stored in these


variables, leading to potential inaccuracies in future operations. Additionally, the same issue


appears if the owner calls the `recoverTokens .`


#### Recommendation


The team is advised to modify the two functions to reset or decrease the `tokensForDev`


and `tokensForMarketing` variables after their execution. This ensures that these


variables accurately reflect the remaining tokens for future operations.


-----

