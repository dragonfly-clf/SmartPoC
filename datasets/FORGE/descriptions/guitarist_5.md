#### RF - Redundant Functions

**Criticality** Minor / Informative

**Location** Guitarist.sol#L1719,1723

**Status** Unresolved

#### Description

The contract contains the `setWallet2` and `setWallet3` functions which update the

the `wallet2` and `wallet3` address variables. However, these wallet variables are

only utilized within the constructor and not in any other part of the contract's logic.

Consequently, the ability to update these addresses via these functions is unnecessary, as

the updated values are not utilized after the deployment of the contract.
```
   function setWallet2(address _wallet2) public onlyOwner {
      wallet2 = _wallet2;
   }
   function setWallet3(address _wallet3) public onlyOwner {
      wallet3 = _wallet3;
   }

#### Recommendation

```
It is recommended to remove the `setWallet2` and `setWallet3` functions from the

contract since the updates performed by these functions to `wallet2` and `wallet3`

addresses are effectively redundant. Since these wallet addresses are not employed in the

contract beyond its initialization phase, maintaining functions to update them serves no

practical purpose and unnecessarily bloats the contract's codebase. Removing these

functions will streamline the contract, enhancing its clarity and efficiency.


-----

