3. Fee limits not coded into contract logic

 Description

 The whitepaper describes fees per transaction to be 3-5%. It is possible for the owner to set fees to >98% thereby siphoning funds from all transactions.

 Remediation

 Include a parity check in the setLiquidityFeePercent() and setTaxFeePercent() to match the parameters specified in the whitepaper, so fees would not completely overshadow the transaction value.

 Status

 Resolved


-----

###### 