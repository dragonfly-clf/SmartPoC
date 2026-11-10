#### RSW - Redundant Storage Writes

**Criticality** Minor / Informative

**Location** SCAI.sol#L257

**Status** Unresolved

#### Description

There are code segments that could be optimized. A segment may be optimized so that it

becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer

operations.

The contract modifies the state of certain variables even when their current state is equal to

the provided argument. As a result, the contract performs redundant storage writes.
```
 _noFee[account] = enabled

#### Recommendation

```
The team is advised to take these segments into consideration and rewrite them so the

runtime will be more performant. That way it will improve the efficiency and performance of

the source code and reduce the cost of executing it.


-----

