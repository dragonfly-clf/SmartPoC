#### RSW - Redundant Storage Writes

**Criticality** Minor / Informative

**Location** bullstoken.sol#L630,634,635,636,637

**Status** Unresolved

#### Description

There are code segments that could be optimized. A segment may be optimized so that it

becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer

operations.

The contract modifies the state of certain variables without checking if their current state

holds the same value as the one given as an argument. As a result, the contract performs

redundant storage writes.
```
 blacklists[_address] = _isBlacklisting;
 limited = _limited;
 uniswapV2Pair = _uniswapV2Pair;
 maxHoldingAmount = _maxHoldingAmount;
 minHoldingAmount = _minHoldingAmount;

#### Recommendation

```
The team is advised to take these segments into consideration and rewrite them so the

runtime will be more performant. That way it will improve the efficiency and performance of

the source code and reduce the cost of executing it.


-----

