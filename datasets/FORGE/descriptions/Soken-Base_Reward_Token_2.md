2) Volatile Code:

 The return values of functions

 swapExactTokensForETHSupportingFeeOnTransferTokens and

 addLiquidityETH are not properly handled.

 Recommendation: 

 We recommend using variables to receive the return value of the

 functions mentioned above and handle both success and failure cases if

 needed by the business logic.

 