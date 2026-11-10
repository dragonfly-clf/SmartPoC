#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor

**Location** contract.sol#L143,144,161,181,785,789,840,849,912,932,933,934,935,953,957,96
2,966,984,988,998,999,1000,1001,1002,1003,1004,1005,1019,418,419,420,423,4
50,451,457,479,480,481,482,483,484

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor|
|---|---|
|Location|contract.sol#L143,144,161,181,785,789,840,849,912,932,933,934,935,953,957,96 2,966,984,988,998,999,1000,1001,1002,1003,1004,1005,1019,418,419,420,423,4 50,451,457,479,480,481,482,483,484|

```
_totalSupply
_lastAddLiquidityTime
_lastRebasedTime
_initRebaseStartTime
_autoAddLiquidity
_autoRebase
owner_address
ZERO
DEAD

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

