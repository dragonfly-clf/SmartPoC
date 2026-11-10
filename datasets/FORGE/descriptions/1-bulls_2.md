#### MSC - Missing Sanity Check


#### Description


The contract is processing variables that have not been properly sanitized and checked that


they form the proper shape. These variables may produce vulnerability issues.


The `setRule` function modifies the state of certain variables, including the


`maxHoldingAmount` and `minHoldingAmount . The two variables indicate the`


maximum and minimum token amount an account can hold respectively. The contract lacks


validation that the `minHoldingAmount` is less than the `maxHoldingAmount .`


#### Recommendation


The team is advised to properly check the variables according to the required


specifications.


-----

