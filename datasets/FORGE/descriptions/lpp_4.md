#### RIS - Redundant If-Else Statement


#### Description


There are code segments that could be optimized. A segment may be optimized so that it


becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer


operations.


The contract has an if-else statement where the if branch doesn't contain any executable


code. Hence, the if branch is redundant.


#### Recommendation


The team is advised to take these segments into consideration and rewrite them so the


runtime will be more performant. That way it will improve the efficiency and performance of


the source code and reduce the cost of executing it. It is recommended to remove the


redundant if-else statement.


-----

