#### TSD - Total Supply Diversion

**Criticality** critical

**Location** contract.sol#L976

**Status** Unresolved

##### Description

The taxed amount is added to the contract's address but it is not subtracted from
the recipient's amount. As a result, the sum of balances is diverted from the total
supply and the contract's balance is violated.

|Criticality|critical|
|---|---|
|Location|contract.sol#L976|
|Status|Unresolved|

```
taxFee = amount.mul(buyTaxFee).div(10000);
...
_balances[address(this)] = _balances[address(this)].add(taxFee);
...
_balances[recipient] = _balances[recipient].add(amount);

```

##### Recommendation

The sum of balances should always be equal with the total supply.


-----

