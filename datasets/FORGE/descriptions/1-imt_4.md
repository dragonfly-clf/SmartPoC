#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L121,60,498,95,555,144,91,107,139,87,116,534,112

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L121,60,498,95,555,144,91,107,139,87,116,534,112|


allowance
setAutomatedMarketMakerPair
approve
name
increaseAllowance
transfer
symbol
decreaseAllowance
isExcludedFromFees
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

