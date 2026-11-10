#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L845,L693,L687 and 8 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L845,L693,L687 and 8 more|

```
rescueToken
cooldownEnabled
manage_blacklist

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

