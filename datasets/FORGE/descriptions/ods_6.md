#### AOI - Arithmetic Operations Inconsistency


#### Description


The contract demonstrates an inconsistency in arithmetic operations. To ensure consistency


and safety, all operations should be executed using one source of truth. In the given code


segment, the addition operation ( marketingFees + botFees + teamFees +

```
restFundsFees ) is performed using a native arithmetic expression, which is not aligned

```

with the rest of the contract that utilizes the SafeMath library methods.


#### Recommendation


The team is advised to use only one source of truth for the arithmetic operations.


-----

