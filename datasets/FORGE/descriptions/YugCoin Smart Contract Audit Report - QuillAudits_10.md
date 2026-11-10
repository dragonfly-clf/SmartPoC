11. Naming convention

 Description

 The codebase is built around Binance Smart Chain not Ethereum. Although there’s no difference in functionality, the syntax of the code contains “Uniswap” and “ETH” instead of “PancakeSwap” and BNB.
 Also, the setMaxTxPercent() function sets the maxTxAmount variable but doesn't adjust transaction limits.

 Recommendation

 Consider renaming the functions and variables to match the deployment environment.
 Also have the setMaxTxPercent() function named according to what it should do.

 Status

 Acknowledged