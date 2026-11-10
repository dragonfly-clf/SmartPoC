#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L339,532,537,542,547,551

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L339,532,537,542,547,551|

```
update_tax
update_tax_Status
update_master_wallet
_newAddress
update_tax_Address
_maxSell
_maxBuy
update_Max_Token_Amount
UTA_BEP20Token

```

##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

