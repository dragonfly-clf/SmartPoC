#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L197,198,211,228,583,594,607,613,635,653,680,697,719,724,882,
915,931,938,944,369,372,384,385,386,412,413,414,429,434

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L197,198,211,228,583,594,607,613,635,653,680,697,719,724,882, 915,931,938,944,369,372,384,385,386,412,413,414,429,434|

```
_maxTxAmount
_maxWalletToken
_sellFee
_buyFee
_TotalFee
Wallet_zero
Wallet_Burn
Wallet_Dev
_isBlacklisted

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

