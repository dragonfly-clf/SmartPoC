#### ROA - Redundant Owner Approval

**Criticality** minor / informative

**Location** contract.sol#L1332

**Status** Unresolved

##### Description

Approving the owner is redundant.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L1332|
|Status|Unresolved|

```
_approve(owner(), owner(), totalSupply());

```

##### Recommendation

The team is advised to remove this check, as there is no reason to approve the
owner.


-----

