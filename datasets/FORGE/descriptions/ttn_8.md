### RES - Redundant Event Statement

**Criticality** Minor / Informative

**Location** TRITON.sol#L997,1002

**Status** Unresolved

### Description

There are code segments that could be optimized. A segment may be optimized so that it

becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer

operations. The contract contains some events statements that are not used in the

contract's implemantation.
```
 event UpdateDividendTracker(
   address indexed newAddress,
   address indexed oldAddress
 );
 event UpdateUniswapV2Router(
   address indexed newAddress,
   address indexed oldAddress
 );

### Recommendation

```
The team is advised to take these segments into consideration and rewrite them so the

runtime will be more performant. That way it will improve the efficiency and performance of

the source code and reduce the cost of executing it. It is recommend removing the unused

event statement from the contract.


-----

