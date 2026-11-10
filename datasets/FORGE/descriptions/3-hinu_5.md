#### CAA - Contract Address Assumption

|Criticality|Minor / Informative|
|---|---|
|Location|contracts/honeyether.sol#L1853|
|Status|Unresolved|


##### Description


The implementation may not follow the expected behavior. The function
```
setRouterContract expects a contract address as an argument. But an address

```
variable could be either a wallet or a contract.


##### Recommendation


The team is advised to proceed with some sanity checks. Some recommendations
are:

 - Check if the address belongs to a contract.

 - If the routerContract implements the interface like HETHToken()


-----

