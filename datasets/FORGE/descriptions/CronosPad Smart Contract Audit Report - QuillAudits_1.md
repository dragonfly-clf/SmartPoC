2. BEP20 Standard violation

 Description

 Implementation of transfer() function does not allow the input of zero amount as it’s demanded in ERC20 and BEP20 standards. This issue may break the interaction with smart contracts that rely on full BEP20 support. Moreover, the GetOwner() function which is a mandatory function is missing from the contract.

 Recommendation

 The transfer function must treat zero amount transfer as a normal transfer and an event must be emitted. Moreover, it is recommended to implement getOwner() function. Reference: https://github.com/bnb-chain/BEPs/blob/master/BEP20.md#5117-transfer

 Status

 Fixed


-----

###### 