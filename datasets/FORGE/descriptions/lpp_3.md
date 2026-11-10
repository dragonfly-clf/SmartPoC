#### MSC - Missing Sanity Check


#### Description


The contract is processing variables that have not been properly sanitized and checked that


they form the proper shape. These variables may produce vulnerability issues.


The `_burnFee` nominator could exceed its denominator `_burnDivisor, potentially`


causing the transfer transaction to revert.


-----

#### Recommendation


The team is advised to properly check the variables according to the required


specifications.



- The `_burnFee` should be lower than the _burnDivisor.



- The `_burnDivisor` should be greater than zero.



- The `MinTx` should be lower than the `MaxTx.`


-----

