#### DDP - Decimal Division Precision

**Criticality** minor / informative

**Location** contract.sol#L297,298

**Status** Unresolved

##### Description

The calculated value is the result of a division. Since Solidity has not floating types,
then the result of a division may miss the decimals precision. As a result, the splitted
shares will not have the exact precision and some funds may not be calculated as
expected.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L297,298|
|Status|Unresolved|

```
_developmentAddress.transfer(amount.div(2));
_marketingAddress.transfer(amount.div(2));

```

##### Recommendation

The contract could calculate the subtraction of the divided funds in the last
calculation in order to avoid the division rounding issue.


-----

