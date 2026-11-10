#### CO - Code Optimization

**Criticality** minor / informative

**Location** contract.sol#L643

**Status** Unresolved

##### Description

There are code segments that could be optimized. A segment may be optimized so
that it becomes a smaller size, consumes less memory, executes more rapidly, or
performs fewer operations. Multiplication by 1 is redundant.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L643|
|Status|Unresolved|


uint256 fee = amount/10000*1;


##### Recommendation

The authors are advised to remove the multiplication by 1 as it is redundant.


-----

