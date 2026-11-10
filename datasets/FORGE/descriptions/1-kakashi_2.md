#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L431,440,446,451,459,554,558,562,566,570,574,579,584,588,593,5
99,604,609,613,619,670,675,681,820,824,828

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L431,440,446,451,459,554,558,562,566,570,574,579,584,588,593,5 99,604,609,613,619,670,675,681,820,824,828|


setAntibotModeWhitelist
setAirdropContract
turnOffAntibotMode
includeInFee
manageAmmPairs
excludeFromFee
reflectionFromToken
totalFees
isExcludedFromReward
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

