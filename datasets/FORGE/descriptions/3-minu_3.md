#### DSM - Data Structure Misuse

**Criticality** minor

**Location** contract.sol#L1060

##### Description

The contract uses the valuable _accounts as an array. The business logic of the
contract does not require to iterate this structure sequentially. Thus, unnecessary
loops are produced that increase the required gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1060|

```
uint256 count = 0;
for (uint256 i = 0; i < _accounts.length; i ++) {
  if (_accounts[i] == to)
    count ++;
}
if (count == 0) {
  _accounts.push(to);
}

```

##### Recommendation

The contract could use a data structure that provides instant access. For instance, a
Set would fit better to the business logic of the contract. This way the time
complexity will be reduced from o(n) to o(1). The latest addition for the expression
```
from == _accounts[0] could be keeped in a separate variable.

```

-----

