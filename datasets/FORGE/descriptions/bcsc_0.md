#### ST - Stops Transactions

**Criticality** minor / informative

**Location** contract.sol#L355,374

**Status** Unresolved

##### Description

The contract owner has the authority to stop the transactions for all users excluding
the owner. The owner may take advantage of it by setting the tradingOpen to true
without setting the launchMode to false.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L355,374|
|Status|Unresolved|

```
if(!authorizations[sender] && !authorizations[recipient]){
  require(tradingOpen,"Trading not open yet");
}

```

The contract cal also stop the sales and transfers by setting the total fees to be
equal to the burn fees.

##### Recommendation

The contract should not allow the contract owner to enable the tradingOpen variable
after the initial toggle.

Read more about the Zero Division issue.


-----

