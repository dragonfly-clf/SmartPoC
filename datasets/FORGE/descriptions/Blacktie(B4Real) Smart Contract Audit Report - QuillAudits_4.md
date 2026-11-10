A.3 Missing events

 Description

 Missing events don't pose any security risk. However, it makes it difficult to track chain events. It is advisable to emit an event whenever a significant action takes place on contract.

 Remediation

 Consider adding events to the following functions:  - setTaxFee  - exemptFromFee  - includeInFee  - updateB4REALTaxAddress  - setAdmin  - transferOwnership

 Status

 Resolved


-----

###### 