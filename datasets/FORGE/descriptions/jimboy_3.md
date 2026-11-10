#### RVD - Redundant Variable Declaration

**Criticality** Minor / Informative

**Location** JIMBOY.sol#L153,171

**Status** Unresolved

#### Description

There are code segments that could be optimized. A segment may be optimized so that it

becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer

operations.

The contract declares certain variables that are not used in a meaningful way by the

contract. As a result, these variables are redundant.
```
 mapping(address => uint256) private _tOwned;
 mapping(address => bool) public bots;
 mapping (address => uint256) public _buyMap;

#### Recommendation

```
The team is advised to take these segments into consideration and rewrite them so the

runtime will be more performant. That way it will improve the efficiency and performance of

the source code and reduce the cost of executing it.


-----

