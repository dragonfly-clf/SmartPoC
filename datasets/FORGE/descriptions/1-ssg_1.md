#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L158,171,184,197,217,222,243,253,1870,1874,1878,1882,1890,1899
,1908,1929,1946,1959,2000,2004,2027,2055,2254,2263,2357,2362,2371,2378,23
82,2396,2411,2415,2433,2445,2462,2759

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L158,171,184,197,217,222,243,253,1870,1874,1878,1882,1890,1899,1908,1929,1946,1959,2000,2004,2027,2055,2254,2263,2357,2362,2371,2378,23 82,2396,2411,2415,2433,2445,2462,2759|

```
aboutMe
getPendingTokens
getPendingBalances
getLastBigBang
getLastAwarded
getLastBuy
jackpotBuybackAmount
jackpotBuyerShareAmount
getJackpot

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

