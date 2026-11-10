#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L1112,1393,1418,1422,1426,1430,1434,1450,1454,1460,1470,1474
,1478

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1112,1393,1418,1422,1426,1430,1434,1450,1454,1460,1470,1474,1478|

```
_minHolder
_isClaimable
_rewardToken
_marketingAddress
_exclude
_addresses
_isLp
_lpAddress
_fee

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

