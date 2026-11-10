#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L429,438,444,449,457,547,551,555,559,563,567,572,577,581,586,5
92,597,602,606,610,661,665,669,780,792,796,800,804

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L429,438,444,449,457,547,551,555,559,563,567,572,577,581,586,5 92,597,602,606,610,661,665,669,780,792,796,800,804|


setAntibotModeWhitelist
setAirdropContract
turnOnAntibotMode
turnOffAntibotMode
isExcludedFromFee
includeInFee
manageAmmPairs
excludeFromFee
reflectionFromToken
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

