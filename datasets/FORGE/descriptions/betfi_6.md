#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L1023,265,518,1054,202,1116,312,185,216,228,293,1070,1031,526
,1016,177,1108,1046,209,247,1039,236

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1023,265,518,1054,202,1116,312,185,216,228,293,1070,1031,526,1016,177,1108,1046,209,247,1039,236|


allowance
burn
approve
totalSupply
enableBlacklist
enableTax
name
triggerTax
transferOwnership
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

