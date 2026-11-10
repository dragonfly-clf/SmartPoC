#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L196,197,210,227,582,593,606,612,634,652 and 31 more

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L196,197,210,227,582,593,606,612,634,652 and 31 more|

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

