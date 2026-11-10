#### CO - Code Optimization

|Criticality|Minor / Informative|
|---|---|
|Location|TorWallet.sol#L233|
|Status|Unresolved|


##### Description


There are code segments that could be optimized. A segment may be optimized so
that it becomes a smaller size, consumes less memory, executes more rapidly, or
performs fewer operations. The variable burnEnabled is not utilized in the
contract's implementation. Hence it is redundant.


##### Recommendation


The team is advised to take into consideration these segments and rewrite them so
the runtime will be more performant. That way it will improve the efficiency and
performance of the source code and reduce the cost of executing it.


-----

