#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L569,213,526,661,636,565,544,582,599,573,560,632,219,764,535,5
49,522,518,235,555,514,540,227,652,656

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L569,213,526,661,636,565,544,582,599,573,560,632,219,764,535,5 49,522,518,235,555,514,540,227,652,656|


setDevWalletAddress
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

