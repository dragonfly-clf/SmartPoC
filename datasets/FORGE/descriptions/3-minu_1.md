#### CO - Code Optimization

**Criticality** minor

**Location** contract.sol#L1050

##### Description

There are code segments that could be optimized. A segment may be optimized so
that it becomes a smaller size, consumes less memory, executes more rapidly, or
performs fewer operations.

The history status could use an enumerated number rather than a string

|Criticality|minor|
|---|---|
|Location|contract.sol#L1050|

```
keccak256(bytes(_history.status)) == keccak256(bytes(buy))

```

##### Recommendation

Rewrite some code segments so the runtime will be more performant.


-----

