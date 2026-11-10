#### ELFM - Exceeds Fees Limit

**Criticality** Minor / Informative

**Location** contracts/WorldToken.sol#L510

**Status** Unresolved

#### Description

The contract owner has the authority to increase over the allowed limit of 25%. The owner

may take advantage of it by calling the `changeTax` function with a high percentage

value.
```
 function contractChangeTax(uint256 newTax) public onlyContract returns
 (bool) {
   require (newTax <= 33, "no more than 33%");
   if (investorProtection == 0) {
     require (newTax >= 5 && newTax <= 15, "tax must be between 5% and
 15%");
   }
   tax = newTax;
   return true;
 }

#### Recommendation

```
The contract could embody a check for the maximum acceptable value. The team should

carefully manage the private keys of the owner’s account. We strongly recommend a

powerful security mechanism that will prevent a single user from accessing the contract

admin functions. Some suggestions are:

  - Introduce a time-locker mechanism with a reasonable delay.

  - Introduce a governance model where users will vote about the actions.

  - Renouncing the ownership will eliminate the threats but it is non-reversible.


-----

