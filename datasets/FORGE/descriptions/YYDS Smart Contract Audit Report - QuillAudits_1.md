A.1: On-chain generated prices can be manipulated

 Client’s Comment

 This tokenPrice just to estimate the amount to swap, it cannot be used anywhere else, so if be manipulated, it does not matter.

 Auditor’s Comment

 price = tokenPrice() is used in calculations. If price is adjusted, the if statement could be skipped from the execution thereby stopping shareholderAddr, Vault and nodes from receiving dividends causing a possible griefing issue for the protocol owners.

### 