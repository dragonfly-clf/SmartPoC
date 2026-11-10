#### RSW - Redundant Storage Writes

**Criticality** Minor / Informative

**Location** JIMBOY.sol#L539

**Status** Unresolved

#### Description

There are code segments that could be optimized. A segment may be optimized so that it

becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer

operations.

The contract modifies the state of certain variables without checking if their current state is

the same as the one passed as an argument. As a result, the contract performs redundant

storage writes.
```
 function toggleSwap(bool _swapEnabled) public onlyOwner {
   swapEnabled = _swapEnabled;
 }

#### Recommendation

```
The team is advised to take these segments into consideration and rewrite them so the

runtime will be more performant. That way it will improve the efficiency and performance of

the source code and reduce the cost of executing it.


-----

