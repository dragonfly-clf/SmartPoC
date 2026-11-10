#### HLI - Holders List Inconsistency

**Criticality** Minor / Informative

**Location** contracts/WorldToken.sol#L937

**Status** Unresolved

#### Description

The current implementation of the contract lacks consistency between the `holders` list

and the `dexAddressList, which can lead to confusion and unexpected behavior. The`

contract adds a user to the holders list only if the user is not already present in the

dexAddressList. However, when the owner adds or removes a user from the dexAddressList

using the `addToDexAddressList` and `removeFromDexAddressList` functions,

respectively, the contract does not update the holders list accordingly.

This inconsistency creates a discrepancy between the two lists, as a user can exist in one

list but not the other, depending on the order of operations or the actions taken by the

contract owner.
```
 if(findIndex(recipient, dexAddressList) == -1){
   if (findIndex(recipient, holders) == -1) {
     holders.push(recipient);
   }
 }

#### Recommendation

```
The team is advised to take these segments into consideration and rewrite them to ensure a

more coherent system, by updating the holders list whenever a user is added to or removed

from the dexAddressList.


-----

