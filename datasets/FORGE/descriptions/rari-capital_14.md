## QSP-15 Unfinished token upgrades

#### Severity: Medium Risk

 Status: Fixed

###### File(s) affected: RariFundTokenUpgrader.sol

 Description: If a user upgrades, but is then sent old fund tokens (which seems possible since it's an ERC20), that user cannot upgrade the received tokens. Further, if token transfers from an
 already updated account occur, the conditional on L69 will never hold, because there will be old tokens in an account that cannot be upgraded (since it was already upgraded). Therefore,

```
finished

```

###### will never be set to true.


###### Recommendation: Clarify to end-users that once an upgrade is performed, tokens that are subsequently received cannot be upgraded. Change the strict equality conditional on L69 to allow
 upgrading any subset of accounts, which would not lead to out-of-gas errors.
 Update: The RariFundTokenUpgrader contract has been removed.


