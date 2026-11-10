#### L01 - Public Function could be Declared External

**Criticality** minor / informative

**Location** contract.sol#L486,499,504,789,1149,1298,1302,1306,1310,1324,1329,1339,1349,
1359,1376,1389

**Status** Unresolved

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L486,499,504,789,1149,1298,1302,1306,1310,1324,1329,1339,1349, 1359,1376,1389|
|Status|Unresolved|

```
owner
renounceOwnership
transferOwnership
supportsInterface
manualMintProfit
name
symbol
decimals
totalSupply

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

