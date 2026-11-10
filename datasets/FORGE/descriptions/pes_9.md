#### RED - Redudant Event Declaration

**Criticality** Minor / Informative

**Location** PEPESMOKING.sol#L713

**Status** Unresolved

#### Description

There are code segments that could be optimized. A segment may be optimized so that it

becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer

operations.

The event `MinTokensBeforeSwapUpdated` is declared and not being used in the

contract. As a result, it is redundant.
```
 event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);

#### Recommendation

```
The team is advised to take these segments into consideration and rewrite them so the

runtime will be more performant. That way it will improve the efficiency and performance of

the source code and reduce the cost of executing it.


-----

