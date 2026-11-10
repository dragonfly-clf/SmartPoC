#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L2228,2387,1386,1422,768,2508,1737,1292,2167,1410,1338,1447,
1510,1535,2240,1373,1476,777,786,1356,2302,2191,1347,1296,1316,799,1472,
1312,1402,1329,791,1406

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L2228,2387,1386,1422,768,2508,1737,1292,2167,1410,1338,1447, 1510,1535,2240,1373,1476,777,786,1356,2302,2191,1347,1296,1316,799,1472, 1312,1402,1329,791,1406|


totalFees
lock
transfer
isExcludedFromReward
symbol
excludeFromFee
unlock
decimals
updatePcsV2Router
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

