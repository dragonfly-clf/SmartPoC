#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor / informative

**Location** contract.sol#L483,162,148,175,497,540,118,256,463,444,436,471,549,262,109,54
8,156,550,546,428,355,552,541,539,506,452,363,551,544,158,159

**Status** Unresolved

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L483,162,148,175,497,540,118,256,463,444,436,471,549,262,109,54 8,156,550,546,428,355,552,541,539,506,452,363,551,544,158,159|
|Status|Unresolved|

```
_teamFeeReceiver
_allowances
WBNB
feeDenominator
_amount
Wallet_txExempt
WETH
maxWallPercent_base1000
_trans

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions.](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

