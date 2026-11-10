#### UCV - Unutilized Contract Variable


#### Description


The contract contains variables that are calculated but not used in subsequent code blocks.


This can lead to wasted computation and unnecessary gas costs, as well as potential


security vulnerabilities.


The variable `_percentage` is initialized and calculated but it is not used in the contract


implementation.


#### Recommendation


It is recommended removing any variables that are calculated but not used in subsequent


code blocks. By removing unused variables, the code will be more efficient and less prone


to vulnerabilities.


-----

