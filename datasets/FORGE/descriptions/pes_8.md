#### RSW - Redundant Storage Writes

**Criticality** Minor / Informative

**Location** PEPESMOKING.sol#L1165,1169,1174,1179,1184,1188

**Status** Unresolved

#### Description

There are code segments that could be optimized. A segment may be optimized so that it

becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer

operations.

The contract updates status of variables even if their current state is the same as the one

passed as an argument. As a result, the contract performs redundant storage writes.


-----

#### Recommendation

The team is advised to take these segments into consideration and rewrite them so the

runtime will be more performant. That way it will improve the efficiency and performance of

the source code and reduce the cost of executing it.


-----

