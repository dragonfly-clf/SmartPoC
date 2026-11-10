#### RS - Redundant Statements

|Criticality|Minor / Informative|
|---|---|
|Status|Unresolved|


##### Description


The contract implements some patterns that unnecessarily increase the gas cost
and make the code complicated. For instance, the following segment.

1. Iterates the array in order to delete every entry.

2. After the clean up checks if it is empty.


Patterns similar to this are repetitive in the contract.


##### Recommendation


The team is advised to take into consideration these segments and rewrite them so
the runtime will be more performant. That way it will improve the efficiency and
performance of the source code and reduce the cost of executing it.


-----

