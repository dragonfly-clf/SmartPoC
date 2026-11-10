#### RED - Redundant Event Declaration

**Criticality** Minor / Informative

**Location** JIMBOY.sol#L186

**Status** Unresolved

#### Description

There are code segments that could be optimized. A segment may be optimized so that it

becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer

operations.

The contract declares certain events that are not used by the contract. As a result, these

events are redundant.
```
 event MaxTxAmountUpdated(uint256 _maxTxAmount);

#### Recommendation

```
The team is advised to take these segments into consideration and rewrite them so the

runtime will be more performant. That way it will improve the efficiency and performance of

the source code and reduce the cost of executing it.


-----

