#### RSW - Redundant Storage Writes


#### Description


There are code segments that could be optimized. A segment may be optimized so that it


becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer


operations.


The contract modifies the state of the following variables without checking if their current


value is the same as the one given as an argument. As a result, the contract performs


redundant storage writes.


#### Recommendation


-----

The team is advised to take these segments into consideration and rewrite them so the


runtime will be more performant. That way it will improve the efficiency and performance of


the source code and reduce the cost of executing it.


-----

