#### L11 - Unnecessary Boolean equality

**Criticality** minor

**Location** contract.sol#L1192 and 1 more

##### Description

The comparison to boolean constants is redundant. Boolean constants can be used
directly and do not need to be compared to true or false.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1192 and 1 more|


allowToSell == true
require(bool,string)(allowToTransfer == true,Not Allow to Transfer)
limitSell == true
preventBotContract == true && sender == uniswapV2Pair && recipient != address(this)
taxStatus == true
allowToTransfer == true
preventBotContract == true && recipient == uniswapV2Pair && sender != address(this)
sender.isContract() == true
limitBuy == true
...


##### Recommendation

Remove the equality to the boolean constant.


-----

