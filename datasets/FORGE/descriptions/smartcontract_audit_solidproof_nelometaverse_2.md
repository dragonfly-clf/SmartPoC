#### Informational issues


-----

|Line|Comment|
|---|---|
|1436|// require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');|


##### Recommendation

###### Remove the commented code, or address them properly.


#### Audit Comments

##### 05. November 2021:

###### • Deployer can lock user funds

 • If _maxTxAmount is set to 0

 • setFreePercent function

 • Fees can be set to max 1000

 • No limitations downwards

 • SetLiquidityFeePercent function

 • Fees can be set to max 1000

 • No limitations downwards

 • PinkAntiBot contract was not provided to Solidproof so it is possible that the onPreTransferCheck function (Line: 1685) could also lock user funds 

24


