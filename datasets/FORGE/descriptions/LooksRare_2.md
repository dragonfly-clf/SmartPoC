2. Lack of two-step process for contract ownership changes|Col2|
|---|---|
|Severity: High|Difficulty: Medium|
|Type: Data Validation|Finding ID: TOB-LR-2|
|Target: LooksRare protocol||


#### Description
The owner of a LooksRare protocol contract can be changed by calling the
```
 transferOwnership function in OpenZeppelin’s Ownable contract. This function

```
internally calls the _transferOwnership function, which immediately sets the contract’s
new owner. Making such a critical change in a single step is error-prone and can lead to
irrevocable mistakes.
```
 /**
  * @dev Leaves the contract without owner. It will not be possible to call
  * `onlyOwner` functions anymore. Can only be called by the current owner.
  *
  * NOTE: Renouncing ownership will leave the contract without an owner,
  * thereby removing any functionality that is only available to the owner.
  */
 function renounceOwnership () public virtual onlyOwner {
   _transferOwnership( address ( 0 ));
 }
 /**
  * @dev Transfers ownership of the contract to a new account (`newOwner`).
  * Can only be called by the current owner.
  */
 function transferOwnership ( address newOwner ) public virtual onlyOwner {
   require (newOwner != address ( 0 ), "Ownable: new owner is the zero address" );
   _transferOwnership(newOwner);
 }
 /**
  * @dev Transfers ownership of the contract to a new account (`newOwner`).
  * Internal function without access restriction.
  */
 function _transferOwnership ( address newOwner ) internal virtual {
   address oldOwner = _owner;
   _owner = newOwner;
   emit OwnershipTransferred(oldOwner, newOwner);

```
Trail of Bits 22 LooksRare Security Assessment


-----

_Figure 2.1: OpenZeppelin’s Ownable contract_

#### Exploit Scenario
Alice and Bob invoke the transferOwnership() function on the LooksRare multisig
wallet to change the address of an existing contract’s owner. They accidentally enter the
wrong address, and ownership of the contract is transferred to the incorrect address. As a
result, access to the contract is permanently revoked.

#### Recommendations
Short term, implement a two-step process to transfer contract ownership, in which the
owner proposes a new address and then the new address executes a call to accept the
role, completing the transfer.

Long term, identify and document all possible actions that can be taken by privileged
accounts ( appendix E ) and their associated risks. This will facilitate reviews of the codebase
and prevent future mistakes.

Trail of Bits 23 LooksRare Security Assessment


-----

|