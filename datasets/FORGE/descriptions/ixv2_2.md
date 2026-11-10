#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L351,L336,L331 and 20 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L351,L336,L331 and 20 more|

```
setSwapSettings
changeTeamWallet
changeMarketingWallet

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

