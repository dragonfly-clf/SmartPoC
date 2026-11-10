#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L386,394,411,443,456,473,496,525,552,938,947,1301,1339,1358,16
06,1612,1632,1639,1658,1669,1678,1697,1704,1711,1725,1732,1741,1745,1759,
1768,1774,1814,1818,1826,2096,2104,2108,2115,2134,2365,2417,2503,2507,251
8,2522,2526

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L386,394,411,443,456,473,496,525,552,938,947,1301,1339,1358,16 06,1612,1632,1639,1658,1669,1678,1697,1704,1711,1725,1732,1741,1745,1759, 1768,1774,1814,1818,1826,2096,2104,2108,2115,2134,2365,2417,2503,2507,251 8,2522,2526|

```
getAllowTokens
updateAllowTokens
getPayoutToken
updatePayoutToken
updateUniswapV2Router
process
getAccountAtIndex
forceSwapAndSendDividends
dividendTokenBalanceOf

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

