#### MDA - Misleading Dead Address

**Criticality** minor / informative

**Location** contract.sol#L2192

**Status** Unresolved

##### Description

The deadWallet address should be immutable. The setDeadWallet function is
misleading, as the contract owner could set the deadWallet variable to any address.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L2192|
|Status|Unresolved|

```
function setDeadWallet(address addr) public onlyOwner {
  deadWallet = addr;
}

```

##### Recommendation

The team is advised to remove this function entirely from the contract.


-----

