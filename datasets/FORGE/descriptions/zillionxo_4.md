#### ZD - Zero Division

**Criticality** critical

**Location** contract.sol#L670

**Status** Unresolved

##### Description

The contract is using variables that may be set to zero as denominators. The
variables liquidity, marketing, and buyback can be set to zero. As a result, the
transactions will revert.

|Criticality|critical|
|---|---|
|Location|contract.sol#L670|
|Status|Unresolved|


function swapAndLiquify(uint256 contractBalance, Taxes memory temp) private lockTheSwap {

uint256 denominator = (temp.liquidity +

**temp.marketing +**
**temp.buyback) * 2;**
uint256 tokensToAddLiquidityWith = (contractBalance * temp.liquidity) / denominator;


##### Recommendation

The contract should prevent those variables to be set to zero or should not allow
executing the corresponding statements.


-----

