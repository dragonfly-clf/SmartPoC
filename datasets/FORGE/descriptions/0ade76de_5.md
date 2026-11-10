#### RS - Redundant Struct

**Criticality** Minor / Informative

**Location** MitaoCat.sol#L302

**Status** Unresolved

#### Description

The contract uses two structures, one for buys and one for sales. These structs contain

only one `uint256` variable. Since it contains only one property then the struct is

redundant.
```
 struct sellFees {
   uint256 operationsFee;
 }
 struct buyFees {
   uint256 operationsFee;
 }

#### Recommendation

```
The team is advised to remove the structs and move the internal property as a contract

state variable.


-----

