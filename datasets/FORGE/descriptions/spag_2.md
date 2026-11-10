#### RES - Redundant Event Statement

**Criticality** Minor / Informative

**Location** SpotPlayArena.sol#L830

**Status** Unresolved

#### Description

There are code segments that could be optimized. A segment may be optimized so that it

becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer

operations.

The `Burn` event statement is not used in the contract's implemantation. Hence, the

event is redundant.
```
 event Burn(address indexed burner, uint256 value);

#### Recommendation

```
The team is advised to take these segments into consideration and rewrite them so the

runtime will be more performant. That way it will improve the efficiency and performance of

the source code and reduce the cost of executing it. It is recommend removing the unused

event statement from the contract..


-----

