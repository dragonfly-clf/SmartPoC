#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L514,515,532,554,967,973,1209,718,732,735 and 5 more

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L514,515,532,554,967,973,1209,718,732,735 and 5 more|

```
_maxTxAmount
MarketingWallet
_MarketingFee
MCISoftwareWallet
_MCISoftwareFee
_liquidityFee
_taxFee
_isBlacklisted
_enabled

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

