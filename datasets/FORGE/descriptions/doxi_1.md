#### TSD - Total Supply Diversion

**Criticality** critical

**Location** contract.sol#L737

**Status** Unresolved

##### Description

The manualBurn() method transfers the caller’s amount to the dead wallet.
Additionally, it decreases the amount from the total supply. As a result, the total
supply is diverse from the sum of balances.

|Criticality|critical|
|---|---|
|Location|contract.sol#L737|
|Status|Unresolved|

```
function manualBurn(uint256 burnAmount) external isAuth
{
  removeAllFee();
    _tTotal = _tTotal - burnAmount;
  _transferStandard(owner(), deadWallet, burnAmount);
  restoreAllFee();
  emit Log("We have manually burned a Total Of:", burnAmount);
}

```

##### Recommendation

The sum of balances should always equal to the total supply.


-----

