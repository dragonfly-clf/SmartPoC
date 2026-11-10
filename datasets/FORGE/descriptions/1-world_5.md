#### RCS - Redundant Conditional Statement

**Criticality** Minor / Informative

**Location** contracts/WorldToken.sol#L804

**Status** Unresolved

#### Description

There are code segments that could be optimized. A segment may be optimized so that it

becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer

operations.

The `findIndex(_msgSender(), claimList)` is checked twice in the `claim`

function. As a result, the following code segments are redundant.
```
 int256 index = findIndex(_msgSender(), claimList);
 require(index >= 0 && uint256(index) < claimList.length, "Invalid index");

#### Recommendation

```
The team is advised to take these segments into consideration and rewrite them so the

runtime will be more performant. That way it will improve the efficiency and performance of

the source code and reduce the cost of executing it.


-----

