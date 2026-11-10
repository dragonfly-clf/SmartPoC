#### STC - Succeeded Transfer Check

**Criticality** minor / informative

**Location** contract.sol#L1066

**Status** Unresolved

##### Description

According to the ERC20 specification, the transfer methods should be checked if
the result is successful. Otherwise, the contract may wrongly assume that the
transfer has been established.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L1066|
|Status|Unresolved|

```
(bool success, ) = payable(insuranceReceiver).call{
  value: amount,
  gas: 30000
}("");
(success, ) = payable(treasuryReceiver).call{
  value: amountETH.sub(amount).sub(amount).sub(amount),
  gas: 30000
}("");

```

##### Recommendation

The contract should check if the result of the transfer methods is successful.


-----

