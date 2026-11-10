#### RSML - Redundant SafeMath Library

|Criticality|Minor / Informative|
|---|---|
|Status|Unresolved|


##### Description


SafeMath is a popular Solidity library that provides a set of functions for performing
common arithmetic operations in a way that is resistant to integer overflows and
underflows.

Starting with Solidity versions that are greater than or equal to 0.8.0, the arithmetic
operations revert on underflow and overflow. As a result, the native functionality of
the Solidity operations replaces the SafeMath library. Hence, the usage of the
SafeMath library adds complexity, overhead and increases unnecessarily the gas
consumption.


##### Recommendation


The team is advised to remove the SafeMath library. Since the version of the
contract is greater than 0.8.0 then the pure Solidity arithmetic operations produce
the same result.

If the previous functionality is required, then the contract could exploit the
```
unchecked { ... } statement.

```
Read more about the breaking change on
[https://docs.soliditylang.org/en/v0.8.16/080-breaking-changes.html#solidity-v0-8-0](https://docs.soliditylang.org/en/v0.8.16/080-breaking-changes.html#solidity-v0-8-0-breaking-changes)
[-breaking-changes.](https://docs.soliditylang.org/en/v0.8.16/080-breaking-changes.html#solidity-v0-8-0-breaking-changes)


-----

