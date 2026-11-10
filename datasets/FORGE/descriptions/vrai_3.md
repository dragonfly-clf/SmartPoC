#### L22 - Potential Locked Ether

**Criticality** Minor / Informative

**Location** VRAI.sol#L551

**Status** Unresolved

#### Description

The contract contains Ether that has been placed into a Solidity contract and is unable to

be transferred. Thus, it is impossible to access the locked Ether. This may produce a

financial loss for the users that have called the payable method.
```
 receive() external payable {}

#### Recommendation

```
The team is advised to either remove the payable method or add a withdraw functionality. it

is important to carefully consider the risks and potential issues associated with locked

Ether.