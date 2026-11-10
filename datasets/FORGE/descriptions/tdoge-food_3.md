#### ZD - Zero Division

**Criticality** medium

**Location** contract.sol#L377

**Status** Unresolved

##### Description

The contract is using variables that may be set to zero as denominators. As a result,
the transactions will revert. The variable swapFee is the result of the following math
operation: _buyFundFee +_buybuybackfee + _buyLPDividendFee + _sellFundFee +
_sellbuybackfee + _sellLPDividendFee + _sellLPFee. All these values can be set to
zero.

|Criticality|medium|
|---|---|
|Location|contract.sol#L377|
|Status|Unresolved|


uint256 lpAmount = tokenAmount * lpFee / swapFee;


##### Recommendation

The contract should prevent those variables to be set to zero or should not allow to
execute the corresponding statements.


-----

