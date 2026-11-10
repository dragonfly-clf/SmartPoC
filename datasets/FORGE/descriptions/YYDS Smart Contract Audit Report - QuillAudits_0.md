High Severity Issues

#### A.1: On-chain generated prices can be manipulated

 File(s)

 YYDS.sol

 Description

 On-chain generated prices are susceptible to price manipulation as these values can be affected by users of the protocol. For now, token price is calculated via the tokenPrice() function below.

 Recommendation(s)

 Use other sources of price validation, as any user with malicious intent and sufficient tokens can easily adjust the token price in between transactions for better prices. Consider using oracles as sources of price validity.

 Status

 Acknowledged


-----

YYDS Audit Report


#### 