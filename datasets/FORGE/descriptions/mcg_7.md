#### L12 - Using Variables before Declaration

**Criticality** minor

**Location** contract.sol#L2026,2025,2027

##### Description

The contract is using a variable before the declaration. This is usually happening
either if it has not been declared yet or the variable has been declared in a different
scope.

|Criticality|minor|
|---|---|
|Location|contract.sol#L2026,2025,2027|

```
lastProcessedIndex
iterations
claims

```

##### Recommendation

The variables should be declared before any usage of them.


-----

