#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L503,L502,L479 and 17 more

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L503,L502,L479 and 17 more|

```
_maxWalletToken
_maxTxAmount
ORIG_CHARITY_FEE

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

