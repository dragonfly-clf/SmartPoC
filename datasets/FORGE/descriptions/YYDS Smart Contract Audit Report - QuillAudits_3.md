A.2: Improper token accounting

 File(s)

 YYDS.sol

 Description

 In swapAndDividend(), YYDS tokens are swapped to their USDT equivalent via the uniswapV2Router. After the swap, all the USDT in tokenReceiver is transferred to the marketingAddr and treasureAddr and this could lead to accounting errors if there was some USDT already in the tokenReceiver before the call to swapAndDividend().

 Scenario

 If another user sends in 1,000 USDT tokens to the tokenReceiver and the swap yields 500 USDT, it’ll send ~1,333USDT to the marketingAddr and ~166USDT to the treasureAddr which is 300% more than expected.

 Recommendation(s)

 The balance before and after the swap can be used to obtain the difference, and transfers would be made based on this difference to avoid accounting errors or misplaced funds.

 Status

 Acknowledged


-----

YYDS Audit Report


#### 