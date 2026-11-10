#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L890

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L890|


marketingETH = (ethGained * ((marketingTokens * 10 ** 18) / taxSum)) / 10 ** 18
baseUnit = amount / denominator
charityETH = (ethGained * ((charityTokens * 10 ** 18) / taxSum)) / 10 ** 18
devETH = (ethGained * ((devTokens * 10 ** 18) / taxSum)) / 10 ** 18
liquidityETH = (ethGained * ((liquidityTokens / 2 * 10 ** 18) / taxSum)) / 10 ** 18
...


##### Recommendation

The multiplications should be prior to the divisions.


-----

