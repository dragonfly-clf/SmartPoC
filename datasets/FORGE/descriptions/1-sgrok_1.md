#### IAC - Insecure Access Control

**Criticality** Critical

**Location** SpaceGrok.sol#L614,621,670,684,720,826

**Status** Unresolved

#### Description

The contract includes certain functions that lack an access control mechanism. These

functions are crucial for the behavior of the contract as they mutate critical state variables.

For instance, the `removeLimits` function, intended to disable the `limitsActive`

variable, lacks proper access control, allowing any user to call it. The

`require(_msgSender() == _msgSender())` statement does not provide effective

authorization protection, as it merely checks if the sender is equal to itself, which is always

true. This exposes a security vulnerability, as unauthorized users can disable limits without

proper authentication.
```
 function removeLimits() external returns (bool) {
   require(_msgSender() == _msgSender());
   limitsActive = false;
   return true;
 }

#### Recommendation

```
The team is strongly advised to implement robust access control mechanisms to restrict the

execution of the `removeLimits` function to authorized addresses. The contract could

use the `onlyOwner` modifier to ensure that only the contract owner can invoke this

function. This ensures that critical functionalities like removing limits are performed only by

authorized entities, enhancing the security of the contract.


-----

