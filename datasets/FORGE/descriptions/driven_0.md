#### ST - Stop Transactions

###### Criticality critical

 Location contract.sol#L2256

##### Description

###### The contract owner has the authority to stop the sales for all users excluding the owner. The owner may take advantage of it by setting the killBlockNum to a high value. As a result, all the buyers will be blacklisted.

|Criticality|critical|
|---|---|
|Location|contract.sol#L2256|

```
if (sender == uniswapPair) {
    if(launchBlockNum + killBlockNum >= block.number) {
       _bAddress[recipient] = true;
    }
}

```

##### Recommendation

###### The team should carefully manage the private keys of the owner’s account. We strongly recommend a powerful security mechanism that will prevent a single user from accessing the contract admin functions. That risk can be prevented by temporarily locking the contract or renouncing ownership.


-----

