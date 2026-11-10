#### CO - Code Optimization


#### Description


There are code segments that could be optimized. A segment may be optimized so that it


becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer


operations.


1. The `contractTokenBalance` could be moved to the initial `if` branch so the

swapping assignment will not be executed.

2. The `success` is assigned but never used. If it is not needed by the business logic

of the contract, then it could be removed.

3. The `half > 0` branch could embody both statements so it does not execute the

same condition twice.


-----

#### Recommendation


The team is advised to take these segments into consideration and rewrite them so the


runtime will be more performant. That way it will improve the efficiency and performance of


the source code and reduce the cost of executing it.


-----

