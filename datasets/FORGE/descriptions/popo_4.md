#### RE - Redundant Events

**Criticality** Minor / Informative

**Location** POPO.sol#L212,214,215

**Status** Unresolved

#### Description

There are code segments that could be optimized. A segment may be optimized so that it

becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer

operations.

The `_changeThreshold,` `_changeFees, and` `SwapAndLiquify` events are not

utilized in the contact's implementation. Hence, they are redundant.
```
 event _changeThreshold(uint256 newThreshold);
 event _changeFees(uint256 buy, uint256 sell);
 event SwapAndLiquify();

#### Recommendation

```
The team is advised to take these segments into consideration and rewrite them so the

runtime will be more performant. That way it will improve the efficiency and performance of

the source code and reduce the cost of executing it. It is recommended to remove

redundant events.


-----

