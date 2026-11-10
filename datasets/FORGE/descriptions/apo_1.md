#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L206,L194,L183 and 15 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L206,L194,L183 and 15 more|

```
buy
airdrop
getBlock

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

