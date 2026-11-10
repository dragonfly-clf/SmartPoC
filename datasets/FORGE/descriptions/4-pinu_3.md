#### CO - Code Optimization

**Criticality** minor

**Location** contract.sol#L1245, 1418

##### Description

There are code segments that could be optimized. A segment may be optimized so
that it becomes a smaller size, consumes less memory, executes more rapidly, or
performs fewer operations. The antiBotEnabled variable is used only in the code
segments below.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1245, 1418|

```
bool public antiBotEnabled;

```
```
function setEnableAntiBot(bool _enable) external onlyOwner {
  antiBotEnabled = _enable;
}

```

##### Recommendation

Rewrite some code segments so the runtime will be more performant. Try to remove
the code segments.


-----

