#### CO - Code Optimization

**Criticality** minor / informative

**Location** contract.sol#L126

**Status** Unresolved

##### Description

There are code segments that could be optimized. A segment may be optimized so
that it becomes a smaller size, consumes less memory, executes more rapidly, or
performs fewer operations.

The data structure allowedTransfer is redundant. Because it is not used in the
contracts’ implementation.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L126|
|Status|Unresolved|


mapping(address => bool) public allowedTransfer;


##### Recommendation

Rewrite some code segments so the runtime will be more performant. The contract
could remove the allowedTransfer data structure.


-----

