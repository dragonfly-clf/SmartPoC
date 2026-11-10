#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L17,194,195,212,1347,1354 and 10 more

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L17,194,195,212,1347,1354 and 10 more|

```
_account
_marketingWallet
DOGERewardsFee

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

