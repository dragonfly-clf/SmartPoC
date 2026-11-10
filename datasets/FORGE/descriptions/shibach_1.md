##### ST - Stop Transactions

**Criticality** Medium

**Location** https://bscscan.com/address/0x9F13F58bFb28Bd84e8C885C47C34D9f648903ea1
#code#L536

###### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _maxTxAmount to a very
small number.

|Criticality|Medium|
|---|---|
|Location|https://bscscan.com/address/0x9F13F58bFb28Bd84e8C885C47C34D9f648903ea1 #code#L536|


**if(from != owner() && to != owner())**

**require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");**


###### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.