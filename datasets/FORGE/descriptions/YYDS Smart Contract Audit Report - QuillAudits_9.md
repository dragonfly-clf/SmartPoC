A.7: Variables can be converted into immutable instead of constant

 Description

 For addresses and values that do not change after deployment, they can be stored as immutable values to reduce gas costs for reading from storage. Some of these variables are tokenOwner, tokenReceiver, uniswapV2Pair and uniswapV2Router all set at deployment time in the constructor.

 Recommendation(s)

 Convert the variables tokenOwner, tokenReceiver, uniswapV2Pair and uniswapV2Router to immutable.

 Status

 Acknowledged


-----

YYDS Audit Report


#### 