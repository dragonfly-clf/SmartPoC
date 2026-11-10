#### STC - Succeeded Transfer Check

**Criticality** minor

**Location** contract.sol#L473,935

##### Description

According to the ERC20 specification, the transfer methods should be checked if
the result is successful. Otherwise, the contract may wrongly assume that the
transfer has been established.

|Criticality|minor|
|---|---|
|Location|contract.sol#L473,935|

```
BUSD.transfer(shareholder, amount);
(bool success, ) = payable(treasuryReceiver).call{
       value: amountETHToTreasuryAndSIF,
       gas: 30000
    }("");

```

##### Recommendation

The contract should check if the result of the transfer methods is successful.


-----

