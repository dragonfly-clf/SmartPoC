#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L812,423,769,899,879,808,787,825,842,816,891,803,875,432,990,4
38,778,792,765,761,451,798,757,783,443,895,959

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L812,423,769,899,879,808,787,825,842,816,891,803,875,432,990,4 38,778,792,765,761,451,798,757,783,443,895,959|


claimTokens
setMaxTxPercent
lock
allowance
name
increaseAllowance
unlock
symbol
decimals
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

