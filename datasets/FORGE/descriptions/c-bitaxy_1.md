##### CO - Code Optimization

|Criticality|Minor / Informative|
|---|---|
|Location|CryptoBitaxy.sol#L832,834,836,838,840|
|Status|Unresolved|


###### Description


There are code segments that could be optimized. A segment may be optimized so
that it becomes a smaller size, consumes less memory, executes more rapidly, or
performs fewer operations. The contract is calculating the same value multiple
times. More specifically, the amount remaining after subtracting the fees. As a
result, the operation is performed multiple times instead of one.


###### Recommendation


The team is advised to take into consideration these segments and rewrite them so
the runtime will be more performant. That way it will improve the efficiency and
performance of the source code and reduce the cost of executing it. A
recommendation would be to extract the
```
amount.sub(burnAmt).sub(charityAmt) into a new variable or overwrite the

```
existing one, and reuse the variable instead.


-----

