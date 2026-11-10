#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L196,268,282,656,454,736,267,661,460,742,194,450,300,442,730,4
52

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L196,268,282,656,454,736,267,661,460,742,194,450,300,442,730,4 52|


_devFee
_amount
_devWalletAddress
WETH
_taxFee
_owner
_maxTxAmount
_enabled
DOMAIN_SEPARATOR
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions.](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

