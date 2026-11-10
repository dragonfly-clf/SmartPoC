#### L01 - Public Function could be Declared External

**Criticality** minor / informative

**Location** contract.sol#L79,87,258,266,283,290,309,332,354,377,397

**Status** Unresolved

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L79,87,258,266,283,290,309,332,354,377,397|
|Status|Unresolved|

```
renounceOwnership
transferOwnership
name
symbol
decimals
totalSupply
transfer
approve
transferFrom

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

