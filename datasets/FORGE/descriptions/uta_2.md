#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L316,325,469,488,532,537,542,547,551

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L316,325,469,488,532,537,542,547,551|

```
update_tax
update_tax_Status
update_master_wallet
update_tax_Address
update_Max_Token_Amount
decreaseAllowance
increaseAllowance
transferOwnership
renounceOwnership

```

##### Recommendation

Use the external attribute for functions never called from the contract.


-----

