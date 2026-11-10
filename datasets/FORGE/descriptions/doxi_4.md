#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor / informative

**Location** contract.sol#L978,961,445,442,972,917,467,440,470,441,416,235,251,460,469,92
1,454,457,234,451,465,966,951,1009,985,466,272,992,448,468

**Status** Unresolved

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L978,961,445,442,972,917,467,440,470,441,416,235,251,460,469,92 1,454,457,234,451,465,966,951,1009,985,466,272,992,448,468|
|Status|Unresolved|

```
_devWallet
_minimumTokensBeforeSwap
_taxFee
_decimals
_charityWallet
_amount
_saleReserveFee
_name
_saleCharityFee

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions.](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

