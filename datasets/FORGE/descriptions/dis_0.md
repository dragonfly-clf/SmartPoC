#### ST - Stops Transactions

**Criticality** Minor / Informative

**Location** Disney.sol#L4220

**Status** Renounced

#### Description

The contract owner has the authority to stop the transactions for all users. The owner may

take advantage of it by calling the `pause` to method.
```
 function _beforeTokenTransfer(
  address from,
  address to,
  uint256 amount
 ) internal override whenNotPaused {
  super._beforeTokenTransfer(from, to, amount);
 }

#### Recommendation

```
The team should carefully manage the private keys of the owner’s account. We strongly

recommend a powerful security mechanism that will prevent a single user from accessing

the contract admin functions. Some suggestions are:

  - Introduce a time-locker mechanism with a reasonable delay.

  - Introduce a multi-sign wallet so that many addresses will confirm the action.

  - Introduce a governance model where users will vote about the actions.

  - Renouncing the ownership will eliminate the threats but it is non-reversible.


#### Team Update


The contract's ownership has been renounced, and the information regarding the


transaction can be accessed through this link:


[https://bscscan.com/tx/0x89a6fd8f6d45c0e56e501152276612e92ef3c93ab1a8f8fd6cf190f](https://bscscan.com/tx/0x89a6fd8f6d45c0e56e501152276612e92ef3c93ab1a8f8fd6cf190f)


65bc59811.


-----

