#### RED - Redundant Event Declaration

**Criticality** Minor / Informative

**Location** contracts/Pry.sol#L1081

**Status** Unresolved

#### Description

There are code segments that could be optimized. A segment may be optimized so that it

becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer

operations.

The contract declares certain events in its code. However, these events are not emitted

within the contract's functions. As a result, these declared events are redundant and serve

no purpose within the contract's current implementation.
```
 event UpdateUniswapV2Router(
   address indexed newAddress,
   address indexed oldAddress
 );

#### Recommendation

```
The team is advised to take these segments into consideration and rewrite them so the

runtime will be more performant. That way it will improve the efficiency and performance of

the source code and reduce the cost of executing it.


-----

