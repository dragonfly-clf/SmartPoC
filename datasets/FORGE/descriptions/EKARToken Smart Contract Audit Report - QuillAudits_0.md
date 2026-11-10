### High severity issues

###### 1. Anyone can mutate the balance of any user
 Line No: 196

 Description Any user on the blockchain can mutate the balance of any user of the token. This breaks the purpose of decentralized token.

 Remediation Remove transferFree method from the code.

 Status: Open

 2. Token decay, Token and Covid tax are not scaled with decimal
 Line No: 165

 05


-----

###### Description Token decay, Token and Covid tax is not scaled with EKARToken decimals; instead of deducting x percent of the amount, x / 10^7 is going to be deducted.

 Remediation Ensure the parameters are scaled with token percentage.

 Status: Open

 3. No events are emitted for critical operations

 Description Proper events are not getting emitted for many of the critical operations; these are highly sensitive administrative operations as following -  - isExcludedFromReward
 - excludeFromFee
 - includeInFee
 - setLiquidityFee
 - setTaxFee
 - setCovidFee

 Events are necessary for tracking changes on blockchain as tracking each transaction is very tedious; events also help as notification in case of administrative compromise and planning mitigation of threat.

 Remediation Emit proper events for crucial operations.

 Status: Open

 0506


-----

