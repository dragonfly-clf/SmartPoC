#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L1203,2089,1463,872,499,887,2108,147,32,1115,436,2030,1515,87
6,540,419,462,521,1123,2112,2181,1231,41,2025,895,36,2188,1666,411,1185,1
250,139,2045,2116,2184,1140,2171,443,2073,481,2061,1174,1816,1683,1534,1
768,2124,1166,470

###### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1203,2089,1463,872,499,887,2108,147,32,1115,436,2030,1515,87 6,540,419,462,521,1123,2112,2181,1231,41,2025,895,36,2188,1666,411,1185,1 250,139,2045,2116,2184,1140,2171,443,2073,481,2061,1174,1816,1683,1534,1 768,2124,1166,470|


allowance
transfer
isExcludedFromDividends
getAccountAtIndex
withdrawnDividendOf
process
excludeMultipleAccountsFromFees
approve
setAutomatedMarketMakerPair
...


###### Recommendation

Use the external attribute for functions never called from the contract.


-----

